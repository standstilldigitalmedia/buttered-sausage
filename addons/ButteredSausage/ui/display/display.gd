@tool
## A visual message display system that shows messages with different severity levels.[br]
## Supports configurable panel limits, hover-to-pause auto-dismiss, and customizable animations.[br]
## Integrates with SSDMResult (from Standstill Core) for displaying operation results with details.[br][br]
##
## Dependencies: Standstill Core addon (provides SSDMResult and SSDMSeverity).[br]
## Configure via ButteredSausageDisplayConfig resource in the inspector.
class_name ButteredSausageDisplay
extends Control

enum PositionPreset {
	TOP_LEFT,        ## Position the panel container at the top-left corner. Panels stack downward from this point.
	TOP_CENTER,      ## Position the panel container at the top-center. Panels stack downward from this point.
	TOP_RIGHT,       ## Position the panel container at the top-right corner. Panels stack downward from this point.
	CENTER_LEFT,     ## Position the panel container at the center-left edge. Container centers vertically at this position.
	CENTER,          ## Position the panel container at the exact screen center. Container centers both horizontally and vertically.
	CENTER_RIGHT,    ## Position the panel container at the center-right edge. Container centers vertically at this position.
	BOTTOM_LEFT,     ## Position the panel container at the bottom-left corner. Panels stack upward from this point.
	BOTTOM_CENTER,   ## Position the panel container at the bottom-center. Panels stack upward from this point.
	BOTTOM_RIGHT     ## Position the panel container at the bottom-right corner. Panels stack upward from this point.
}

@export_group("Positioning")
@export var panel_width: float = 400.0  ## Width of each message panel in pixels. All panels in the display will use this width.
@export var position_preset: PositionPreset = PositionPreset.CENTER  ## Screen position where panels appear. Choose from 9 preset positions (corners, edges, center).
@export var margin_from_edge: float = 20.0  ## Distance in pixels between panels and the screen edge. Applies to all position presets.
@export var reverse_panel_order: bool = false  ## Stack direction for multiple panels. False = new panels at top, True = new panels at bottom.

@export_group("Panels")
@export var success_panel: PackedScene  ## Visual styling and behavior for SUCCESS severity panels (green by default)
@export var error_panel: PackedScene  ## Visual styling and behavior for ERROR severity panels (red by default)
@export var warning_panel: PackedScene  ## Visual styling and behavior for WARNING severity panels (yellow by default)
@export var info_panel: PackedScene  ## Visual styling and behavior for INFO severity panels (blue by default)

@export_group("Panel Limits")
## Maximum number of panels visible at once. 0 = unlimited panels, 1 = single panel mode (uses priority), 2+ = limited mode (FIFO removal when limit reached).
@export var max_visible_panels: int = 0
## Priority for ERROR panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var error_priority: int = 4
## Priority for SUCCESS panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var success_priority: int = 3
## Priority for WARNING panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var warning_priority: int = 2
## Priority for INFO panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var info_priority: int = 1

@export_group("Control")
@export var content_container: VBoxContainer

var _positioning_applied: bool = false
var _target_position: Vector2 = Vector2.ZERO
var _anchor_to_bottom: bool = false
var _creating_panel: bool = false  # Prevents race conditions when creating multiple panels


## Populates the display with messages from an SSDMResult object.[br]
## Shows the main message and all detail messages.[br][br]
##
## @param result - The SSDMResult containing message and details to display
func populate_from_result(result: SSDMResult) -> void:
	create_message(result.message, result.severity)
	for detail in result.details:
		create_message(detail["message"], detail["severity"])
		
		
## Closes all message panels and hides the display.[br][br]
func clear_all_panels() -> void:
	for child in content_container.get_children():
		if child is ButteredSausagePanelBase:
			child.close()
	hide()
	
	
## Immediately removes a panel from the tree and frees it.[br]
## Stops timers and animations before removal.[br][br]
##
## @param panel - The panel to remove[br]
func _remove_panel_immediately(panel: ButteredSausagePanelBase) -> void:
	# Stop any timers and mark as closing to stop looping animations
	panel.is_closing = true
	if panel.auto_dismiss_timer and is_instance_valid(panel.auto_dismiss_timer):
		panel.auto_dismiss_timer.stop()
	# Remove from tree immediately to prevent any further processing
	content_container.remove_child(panel)
	# Queue for deletion
	panel.queue_free()
	
	
## Returns the priority value for a given severity level.[br]
## Used for single panel mode to determine which panel to keep.[br][br]
##
## @param severity - The severity level[br]
## @return The priority value from display config[br]
func _get_severity_priority(severity: int) -> int:
	match severity:
		SSDMSeverity.Level.ERROR:
			return error_priority
		SSDMSeverity.Level.SUCCESS:
			return success_priority
		SSDMSeverity.Level.WARNING:
			return warning_priority
		SSDMSeverity.Level.INFO:
			return info_priority
	return 0


## Enforces max_visible_panels limit by closing panels.[br]
## For single panel mode, prioritizes by severity. For limited mode, uses FIFO.[br][br]
##
## @param new_severity - The severity of the panel about to be created[br]
## @return True if the new panel should be created, false otherwise[br]
func _enforce_panel_limit(new_severity: int) -> bool:
	if max_visible_panels <= 0:
		return true  # Unlimited panels, always create

	var panels: Array[ButteredSausagePanelBase] = []
	for child in content_container.get_children():
		if child is ButteredSausagePanelBase:
			# Skip panels that are closing
			if child.is_closing:
				continue
			panels.append(child)

	# Special case: max_visible_panels = 1 (single panel mode)
	# Only create new panel if it has higher or equal priority than existing
	if max_visible_panels == 1:
		# If no valid existing panels, allow creation
		if panels.is_empty():
			return true

		var new_priority = _get_severity_priority(new_severity)
		var highest_existing_priority = -1
		var highest_priority_panel: ButteredSausagePanelBase = null

		# Find the panel with the highest priority
		for panel in panels:
			var panel_priority = _get_severity_priority(panel.severity)
			if panel_priority > highest_existing_priority:
				highest_existing_priority = panel_priority
				highest_priority_panel = panel

		# If new panel has higher priority than the best existing panel, replace all
		# If equal priority, new panel wins (most recent behavior)
		if new_priority >= highest_existing_priority:
			# Remove all existing panels
			for panel in panels:
				_remove_panel_immediately(panel)
			return true
		else:
			# Existing panel has higher priority, don't create new one
			# But still remove any other lower priority panels to ensure only one remains
			for panel in panels:
				if panel != highest_priority_panel:
					_remove_panel_immediately(panel)
			return false

	# For max_visible_panels > 1: Remove oldest panels (FIFO) until under limit
	# We want to stay at (max - 1) to make room for the new panel about to be added
	while panels.size() >= max_visible_panels:
		# Determine which panel is oldest based on reverse_panel_order setting
		var oldest_panel: ButteredSausagePanelBase
		if reverse_panel_order:
			# When reverse order is enabled, new panels are inserted at index 0
			# So the oldest panel is at the END of the array
			oldest_panel = panels[panels.size() - 1]
			panels.remove_at(panels.size() - 1)
		else:
			# Default order: new panels are added at the end
			# So the oldest panel is at index 0
			oldest_panel = panels[0]
			panels.remove_at(0)
		_remove_panel_immediately(oldest_panel)

	return true  # Always create for limited mode
	

## Updates content container position based on preset and current parent size.[br]
## Called every frame to keep position correct as container size changes.[br][br]
func _update_position() -> void:
	if not _positioning_applied:
		return

	var margin: float = margin_from_edge
	var width: float = panel_width

	# Use get_parent_area_size() to get the actual available space
	var parent_size: Vector2 = get_parent_area_size()
	var container_height: float = content_container.get_combined_minimum_size().y
	var pos: Vector2 = Vector2.ZERO

	match position_preset:
		PositionPreset.TOP_LEFT:
			pos = Vector2(margin, margin)

		PositionPreset.TOP_CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, margin)

		PositionPreset.TOP_RIGHT:
			pos = Vector2(parent_size.x - width - margin, margin)

		PositionPreset.CENTER_LEFT:
			pos = Vector2(margin, (parent_size.y - container_height) / 2.0)

		PositionPreset.CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, (parent_size.y - container_height) / 2.0)

		PositionPreset.CENTER_RIGHT:
			pos = Vector2(parent_size.x - width - margin, (parent_size.y - container_height) / 2.0)

		PositionPreset.BOTTOM_LEFT:
			pos = Vector2(margin, parent_size.y - container_height - margin)

		PositionPreset.BOTTOM_CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, parent_size.y - container_height - margin)

		PositionPreset.BOTTOM_RIGHT:
			pos = Vector2(parent_size.x - width - margin, parent_size.y - container_height - margin)

	content_container.position = pos
	
	
## Applies the position preset from display config to the content container.[br]
## Sets up positioning mode and flags, then updates position.[br][br]
func _apply_position_preset() -> void:
	if _positioning_applied:
		return

	var margin: float = margin_from_edge
	var width: float = panel_width

	# Use layout_mode 0 (unmanaged positioning) - simplest approach
	content_container.set("layout_mode", 0)

	# Set width
	content_container.custom_minimum_size.x = width
	content_container.custom_minimum_size.y = 0

	# Set size flags
	# 0 = shrink to beginning (default when SIZE_SHRINK_CENTER and SIZE_SHRINK_END not set)
	content_container.size_flags_horizontal = 0
	content_container.size_flags_vertical = 0

	# Determine if this preset needs bottom anchoring
	_anchor_to_bottom = position_preset in [
		PositionPreset.BOTTOM_LEFT,
		PositionPreset.BOTTOM_CENTER,
		PositionPreset.BOTTOM_RIGHT
	]

	# Set flag BEFORE calling update so it doesn't return early
	_positioning_applied = true

	# Initial position (will be updated every frame for bottom positioning)
	_update_position()
	
		
## Creates and displays a message panel with specified severity.[br][br]
##
## @param msg - The message text to display[br]
## @param severity - The severity level (use Severity enum)
func create_message(msg: String, severity: int) -> void:
	# Acquire lock FIRST to prevent race conditions with simultaneous messages
	while _creating_panel:
		await get_tree().process_frame
	_creating_panel = true

	# Apply positioning if not yet applied
	if !_positioning_applied:
		show()  # Must be visible for sizing
		await get_tree().process_frame  # Wait for layout
		_apply_position_preset()

	# Check for duplicate message
	var found: bool = false
	for child in content_container.get_children():
		if child is ButteredSausagePanelBase:
			if child.message_label.text == msg:
				found = true
				break

	if found:
		# Duplicate message found, release lock and exit
		_creating_panel = false
		show()
		return

	# No duplicate found, proceed to create panel
	# Check limit before creating
	if not _enforce_panel_limit(severity):
		_creating_panel = false
		return  # Don't create panel, existing higher priority panel takes precedence

	var panel: ButteredSausagePanelBase
	match severity:
		SSDMSeverity.Level.SUCCESS:
			panel = success_panel.instantiate() as ButteredSausagePanelBase
		SSDMSeverity.Level.ERROR:
			panel = error_panel.instantiate() as ButteredSausagePanelBase
		SSDMSeverity.Level.WARNING:
			panel = warning_panel.instantiate() as ButteredSausagePanelBase
		SSDMSeverity.Level.INFO:
			panel = info_panel.instantiate() as ButteredSausagePanelBase

	for step in panel.entrance_animation_chain:
		if step.panel_animation:
			step.panel_animation.panel_width = panel_width
	for step in panel.exit_animation_chain:
		if step.panel_animation:
			step.panel_animation.panel_width = panel_width

	# Add to tree so subsequent messages can see it
	content_container.add_child(panel)

	# If reverse order is enabled, move new panel to the top (index 0)
	if reverse_panel_order:
		content_container.move_child(panel, 0)

	# Setup the panel (after it's in tree so timer can start)
	panel.setup(msg)

	# Release the lock so other messages can proceed
	_creating_panel = false

	panel.slide_open()
	show()
	
					
## Shows an error message.[br][br]
##
## @param message - The error message to display[br]
func show_error(message: String) -> void:
	create_message(message, SSDMSeverity.Level.ERROR)


## Shows a success message.[br][br]
##
## @param message - The success message to display[br]
func show_success(message: String) -> void:
	create_message(message, SSDMSeverity.Level.SUCCESS)


## Shows a warning message.[br][br]
##
## @param message - The warning message to display[br]
func show_warning(message: String) -> void:
	create_message(message, SSDMSeverity.Level.WARNING)


## Shows an info message.[br][br]
##
## @param message - The info message to display[br]
func show_info(message: String) -> void:
	create_message(message, SSDMSeverity.Level.INFO)
	

## Updates position every frame to keep panels positioned correctly.[br][br]
##
## @param _delta - Frame delta time (unused)[br]
func _process(_delta: float) -> void:
	if _positioning_applied:
		_update_position()


## Initializes the display and propagates panel width to animation configs.[br][br]
func _ready() -> void:
	hide()

	# Clear static style cache to ensure fresh styleboxes are created
	# This prevents stale cached styles from persisting across editor reloads
	ButteredSausagePanelBase.cached_styles.clear()
