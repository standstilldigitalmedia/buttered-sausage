@tool
## A visual error/message display system that shows messages with different severity levels.[br]
## Supports stacking multiple messages or showing only the highest priority message.[br]
## Integrates with SSDMResult for displaying operation results with details.[br]
## Configure colors, timings, and styling through exported variables in the inspector.
class_name ButteredSausageDisplay
extends PanelContainer

enum Severity {
	SUCCESS,
	INFO,
	WARNING,
	ERROR
}

@export var message_panel_scene: PackedScene
@export var content_container: VBoxContainer
@export var global_config: ButteredSausageGlobalConfig

var stacking_enabled: bool = true
var current_panel: ButteredSausagePanel = null


## Closes all message panels and hides the display.
func clear_messages() -> void:
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			child.close()
	hide()
			
			
## Keeps only the panel with the highest priority severity and closes all others.[br][br]
## Priority order: ERROR > SUCCESS > WARNING > INFO
func keep_highest_priority_panel() -> void:
	var panels: Array = []
	if !content_container:
		push_error("content_container must be set on buttered_sausage_display.tscn in the inspector")
		return
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			panels.append(child)
	if panels.size() == 0:
		current_panel = null
		return
	var highest_priority_panel = panels[0]
	var highest_priority = _get_severity_priority(highest_priority_panel.severity)
	for panel in panels:
		var priority = _get_severity_priority(panel.severity)
		if priority > highest_priority:
			highest_priority = priority
			highest_priority_panel = panel
	for panel in panels:
		if panel != highest_priority_panel:
			panel.close()
	current_panel = highest_priority_panel


## Enables or disables message stacking. When disabled, only one message is shown at a time.[br][br]
##
## @param enabled - True to allow multiple messages, false to show only highest priority
func set_stacking_enabled(enabled: bool) -> void:
	stacking_enabled = enabled
	if not enabled:
		keep_highest_priority_panel()


## Closes all message panels and hides the display.[br][br]
func clear_all_panels() -> void:
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			child.close()
	current_panel = null
	hide()
	
	
## Creates and displays a message panel with specified severity.[br][br]
##
## @param msg - The message text to display[br]
## @param severity - The severity level (use Severity enum)
func create_message(msg: String, severity: int) -> void:
	if not stacking_enabled and current_panel != null and is_instance_valid(current_panel):
		if current_panel.panel_config.severity == severity:
			current_panel.update_message(msg)
			return
		else:
			current_panel.slide_closed()
	if not stacking_enabled:
		clear_all_panels()
	var found: bool = false
	for child in content_container.get_children():
		if child is ButteredSausagePanel:
			if child.message_label.text == msg:
				found = true
				break
	if !found:
		var panel = message_panel_scene.instantiate()
		if !message_panel_scene:
			push_error("message_panel_scene must be set on buttered_sausage_display.tscn in the inspector")
			return
		content_container.add_child(panel)
		match severity:
			ButteredSausageDisplay.Severity.SUCCESS:
				panel.setup(msg, global_config.success_config)
			ButteredSausageDisplay.Severity.ERROR:
				panel.setup(msg, global_config.error_config)
			ButteredSausageDisplay.Severity.WARNING:
				panel.setup(msg, global_config.warning_config)
			ButteredSausageDisplay.Severity.INFO:
				panel.setup(msg, global_config.info_config)
		panel.slide_open()
		if not stacking_enabled:
			current_panel = panel
	show()


## Populates the display with messages from an SSDMResult object.[br]
## If stacking is enabled, shows the main message and all detail messages.[br]
## If stacking is disabled, shows only the highest priority message.[br][br]
##
## @param result - The SSDMResult containing message and details to display
func populate_from_result(result: ButteredSausage) -> void:
	if stacking_enabled:
		create_message(result.message, result.severity)
		for detail in result.details:
			create_message(detail["message"], detail["severity"])
	else:
		var highest_severity = result.severity
		var highest_message = result.message
		for detail in result.details:
			if _get_severity_priority(detail["severity"]) > _get_severity_priority(highest_severity):
				highest_severity = detail["severity"]
				highest_message = detail["message"]
		create_message(highest_message, highest_severity)
	show()
		
					
## Shows an error message.[br][br]
##
## @param message - The error message to display
func show_error(message: String) -> void:
	create_message(message, Severity.ERROR)


## Shows a success message.[br][br]
##
## @param message - The success message to display
func show_success(message: String) -> void:
	create_message(message, Severity.SUCCESS)


## Shows a warning message.[br][br]
##
## @param message - The warning message to display
func show_warning(message: String) -> void:
	create_message(message, Severity.WARNING)


## Shows an info message.[br][br]
##
## @param message - The info message to display
func show_info(message: String) -> void:
	create_message(message, Severity.INFO)
			

func _get_severity_priority(severity: int) -> int:
	match severity:
		Severity.ERROR:
			return 3
		Severity.SUCCESS:
			return 2
		Severity.WARNING:
			return 1
		Severity.INFO:
			return 0
	return 0


func _ready() -> void:
	hide()
	# Propagate panel_width from global config to all animator configs
	for severity_config in [global_config.success_config, global_config.error_config,
							global_config.warning_config, global_config.info_config]:
		for anim_config in severity_config.animation_chain:
			anim_config.panel_width = global_config.panel_width
		for anim_config in severity_config.close_animation_chain:
			anim_config.panel_width = global_config.panel_width
