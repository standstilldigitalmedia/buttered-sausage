@tool
## A visual message display system that shows messages with different severity levels.[br]
## Supports configurable panel limits, hover-to-pause auto-dismiss, and customizable animations.[br]
## Integrates with ButteredSausage result pattern for displaying operation results with details.[br][br]
##
## Configure via ButteredSausageDisplayConfig resource in the inspector.
class_name ButteredSausageDisplay
extends Control

@export var message_panel_scene: PackedScene
@export var content_container: VBoxContainer
@export var global_config: ButteredSausageDisplayConfig

var _positioning_applied: bool = false
var _target_position: Vector2 = Vector2.ZERO
var _anchor_to_bottom: bool = false


## Populates the display with messages from a ButteredSausage result object.[br]
## Shows the main message and all detail messages.[br][br]
##
## @param result - The ButteredSausage result containing message and details to display
func populate_from_result(result: ButteredSausage) -> void:
	create_message(result.message, result.severity)
	for detail in result.details:
		create_message(detail["message"], detail["severity"])
		
		
## Closes all message panels and hides the display.[br][br]
func clear_all_panels() -> void:
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			child.close()
	hide()
	
	
## Immediately removes a panel from the tree and frees it.[br]
## Stops timers and animations before removal.[br][br]
##
## @param panel - The panel to remove[br]
func _remove_panel_immediately(panel: ButteredSausagePanel) -> void:
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
## @return The priority value from global config[br]
func _get_severity_priority(severity: int) -> int:
	match severity:
		ButteredSausageSeverity.Level.ERROR:
			return global_config.error_priority
		ButteredSausageSeverity.Level.SUCCESS:
			return global_config.success_priority
		ButteredSausageSeverity.Level.WARNING:
			return global_config.warning_priority
		ButteredSausageSeverity.Level.INFO:
			return global_config.info_priority
	return 0


## Enforces max_visible_panels limit by closing panels.[br]
## For single panel mode, prioritizes by severity. For limited mode, uses FIFO.[br][br]
##
## @param new_severity - The severity of the panel about to be created[br]
## @return True if the new panel should be created, false otherwise[br]
func _enforce_panel_limit(new_severity: int) -> bool:
	if global_config.max_visible_panels <= 0:
		return true  # Unlimited panels, always create

	var panels: Array[ButteredSausagePanel] = []
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			panels.append(child)

	# Special case: max_visible_panels = 1 (single panel mode)
	# Only create new panel if it has higher or equal priority than existing
	if global_config.max_visible_panels == 1:
		var new_priority = _get_severity_priority(new_severity)
		var highest_existing_priority = -1
		var highest_priority_panel: ButteredSausagePanel = null

		# Find the panel with the highest priority
		for panel in panels:
			if not panel.panel_config:
				continue
			var panel_priority = _get_severity_priority(panel.panel_config.severity)
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
	while panels.size() >= global_config.max_visible_panels:
		# Determine which panel is oldest based on reverse_panel_order setting
		var oldest_panel: ButteredSausagePanel
		if global_config.reverse_panel_order:
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

	var margin: float = global_config.margin_from_edge
	var width: float = global_config.panel_width

	# Use get_parent_area_size() to get the actual available space
	var parent_size: Vector2 = get_parent_area_size()
	var container_height: float = content_container.size.y
	var pos: Vector2 = Vector2.ZERO

	match global_config.position_preset:
		ButteredSausageDisplayConfig.PositionPreset.TOP_LEFT:
			pos = Vector2(margin, margin)

		ButteredSausageDisplayConfig.PositionPreset.TOP_CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, margin)

		ButteredSausageDisplayConfig.PositionPreset.TOP_RIGHT:
			pos = Vector2(parent_size.x - width - margin, margin)

		ButteredSausageDisplayConfig.PositionPreset.CENTER_LEFT:
			pos = Vector2(margin, (parent_size.y - container_height) / 2.0)

		ButteredSausageDisplayConfig.PositionPreset.CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, (parent_size.y - container_height) / 2.0)

		ButteredSausageDisplayConfig.PositionPreset.CENTER_RIGHT:
			pos = Vector2(parent_size.x - width - margin, (parent_size.y - container_height) / 2.0)

		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_LEFT:
			pos = Vector2(margin, parent_size.y - container_height - margin)

		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_CENTER:
			pos = Vector2((parent_size.x - width) / 2.0, parent_size.y - container_height - margin)

		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_RIGHT:
			pos = Vector2(parent_size.x - width - margin, parent_size.y - container_height - margin)

	content_container.position = pos
	
	
## Applies the position preset from global config to the content container.[br]
## Sets up positioning mode and flags, then updates position.[br][br]
func _apply_position_preset() -> void:
	if _positioning_applied:
		return

	var margin: float = global_config.margin_from_edge
	var width: float = global_config.panel_width

	# Use layout_mode 0 (unmanaged positioning) - simplest approach
	content_container.set("layout_mode", 0)

	# Set width
	content_container.custom_minimum_size.x = width
	content_container.custom_minimum_size.y = 0

	# Set size flags
	content_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	content_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	# Determine if this preset needs bottom anchoring
	_anchor_to_bottom = global_config.position_preset in [
		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_LEFT,
		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_CENTER,
		ButteredSausageDisplayConfig.PositionPreset.BOTTOM_RIGHT
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
	# Apply positioning FIRST if not yet applied
	if not _positioning_applied:
		show()  # Must be visible for sizing
		await get_tree().process_frame  # Wait for layout
		_apply_position_preset()

	# Check for duplicate message
	var found: bool = false
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			if child.message_label.text == msg:
				found = true
				break
	if !found:
		# Enforce panel limit before creating new panel
		if not _enforce_panel_limit(severity):
			return  # Don't create panel, existing higher priority panel takes precedence

		var panel = message_panel_scene.instantiate()
		if !message_panel_scene:
			push_error("message_panel_scene must be set on buttered_sausage_display.tscn in the inspector")
			return
		content_container.add_child(panel)

		# If reverse order is enabled, move new panel to the top (index 0)
		if global_config.reverse_panel_order:
			content_container.move_child(panel, 0)

		match severity:
			ButteredSausageSeverity.Level.SUCCESS:
				panel.setup(msg, global_config.success_config)
			ButteredSausageSeverity.Level.ERROR:
				panel.setup(msg, global_config.error_config)
			ButteredSausageSeverity.Level.WARNING:
				panel.setup(msg, global_config.warning_config)
			ButteredSausageSeverity.Level.INFO:
				panel.setup(msg, global_config.info_config)
		panel.slide_open()

	show()
	
					
## Shows an error message.[br][br]
##
## @param message - The error message to display[br]
func show_error(message: String) -> void:
	create_message(message, ButteredSausageSeverity.Level.ERROR)


## Shows a success message.[br][br]
##
## @param message - The success message to display[br]
func show_success(message: String) -> void:
	create_message(message, ButteredSausageSeverity.Level.SUCCESS)


## Shows a warning message.[br][br]
##
## @param message - The warning message to display[br]
func show_warning(message: String) -> void:
	create_message(message, ButteredSausageSeverity.Level.WARNING)


## Shows an info message.[br][br]
##
## @param message - The info message to display[br]
func show_info(message: String) -> void:
	create_message(message, ButteredSausageSeverity.Level.INFO)
	

## Updates position every frame to keep panels positioned correctly.[br][br]
##
## @param _delta - Frame delta time (unused)[br]
func _process(_delta: float) -> void:
	if _positioning_applied:
		_update_position()


## Initializes the display and propagates panel width to animation configs.[br][br]
func _ready() -> void:
	hide()

	# Propagate panel_width from global config to all animator configs
	for severity_config in [global_config.success_config, global_config.error_config,
							global_config.warning_config, global_config.info_config]:
		for anim_config in severity_config.animation_chain:
			anim_config.panel_width = global_config.panel_width
		for anim_config in severity_config.close_animation_chain:
			anim_config.panel_width = global_config.panel_width
