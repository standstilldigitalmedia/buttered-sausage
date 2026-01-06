@tool
## An individual message panel that displays within SSDMErrorDisplay with animated entrance/exit.[br]
## Handles message display, auto-dismiss timers, and severity-based styling and animations.
class_name ButteredSausagePanel
extends Control

const PANEL_THEME: String = "panel"

var box_rounding: int = 4
var success_time: float = 3.0
var warning_time: float = 4.0
var info_time: float = 6.0
var error_time: float = 6.0
var success_color: Color = Color(0.2, 0.6, 0.2, 0.9)
var success_border_color: Color = Color(0.1, 0.5, 0.1, 0.9)
var info_color: Color = Color(0.2, 0.4, 0.8, 0.9)
var info_border_color: Color = Color(0.1, 0.3, 0.7, 0.9)
var warning_color: Color = Color(0.8, 0.6, 0.1, 0.9)
var warning_border_color: Color = Color(0.7, 0.5, 0.0, 0.9)
var error_color: Color = Color(0.8, 0.2, 0.2, 0.9)
var error_border_color: Color = Color(0.7, 0.1, 0.1, 0.9)
var border_width_bottom: int = 5
var border_width_left: int = 3

@export var panel_container: PanelContainer
@export var message_label: RichTextLabel
@export var error_close_button: Button

var severity: int
var animator: ButteredSausageAnimator
var is_closing: bool = false
var auto_dismiss_timer: Timer


## Updates the displayed message text without creating a new panel.[br][br]
##
## @param message - The new message text to display
func update_message(message: String) -> void:
	message_label.text = message
	
	
## Configures the slide animator with severity-specific animation effects.[br]
## ERROR panels scale in with fade and bounce. WARNING panels bounce. SUCCESS and INFO slide smoothly.[br][br]
##
## @param severity - The severity level determining which animation to apply
func apply_animations(severity: ButteredSausageDisplay.Severity) -> void:
	animator = ButteredSausageAnimator.new(self, panel_container)
	match severity:
		ButteredSausageDisplay.Severity.SUCCESS:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE) \
				.with_speed(0.4) \
				.with_fade() 
		ButteredSausageDisplay.Severity.INFO:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE) \
				.with_speed(0.4)
		ButteredSausageDisplay.Severity.WARNING:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE) \
				.with_speed(1.4)
		ButteredSausageDisplay.Severity.ERROR:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE) \
				.with_scale(Vector2(0.3, 1)) \
				.with_rotation_pivot_center() \
				.with_rotation(0, 360)
		
			
## Applies severity-specific background color to the panel.[br][br]
##
## @param sev - The severity level determining the panel color
func apply_style(sev: int) -> void:
	var style_box = StyleBoxFlat.new()
	style_box.corner_radius_top_left = box_rounding
	style_box.corner_radius_top_right = box_rounding
	style_box.corner_radius_bottom_left = box_rounding
	style_box.corner_radius_bottom_right = box_rounding
	style_box.border_width_bottom = border_width_bottom
	style_box.border_width_left = border_width_left
	match sev:
		ButteredSausageDisplay.Severity.SUCCESS:
			style_box.bg_color = success_color
			style_box.border_color = success_border_color
		ButteredSausageDisplay.Severity.INFO:
			style_box.bg_color = info_color
			style_box.border_color = info_border_color
		ButteredSausageDisplay.Severity.WARNING:
			style_box.bg_color = warning_color
			style_box.border_color = warning_border_color
		ButteredSausageDisplay.Severity.ERROR:
			style_box.bg_color = error_color
			style_box.border_color = error_border_color
	panel_container.add_theme_stylebox_override(PANEL_THEME, style_box)
	
	
## Returns the auto-dismiss timeout duration based on severity.[br]
## Default: SUCCESS: 3s, WARNING: 4s, INFO: 6s, ERROR: 6s[br][br]
##
## @param sev - The severity level[br]
## @return The timeout duration in seconds
func get_dismiss_time(sev: int) -> float:
	match sev:
		ButteredSausageDisplay.Severity.SUCCESS:
			return success_time
		ButteredSausageDisplay.Severity.WARNING:
			return warning_time
		ButteredSausageDisplay.Severity.INFO:
			return info_time
		ButteredSausageDisplay.Severity.ERROR:
			return error_time
		_:
			return error_time
	
	
## Initializes the panel with message, severity, styling, animations, and auto-dismiss timer.[br][br]
##
## @param msg - The message text to display[br]
## @param sev - The severity level[br]
## @param auto_dismiss - If true, panel will auto-close after a timeout[br]
## @param config - Optional configuration dictionary with colors, timings, and styling
func setup(msg: String, sev: int, auto_dismiss: bool = false, config: Dictionary = {}) -> void:
	# Apply configuration if provided
	if not config.is_empty():
		if config.has("success_duration"): success_time = config.success_duration
		if config.has("warning_duration"): warning_time = config.warning_duration
		if config.has("info_duration"): info_time = config.info_duration
		if config.has("error_duration"): error_time = config.error_duration
		if config.has("success_color"): success_color = config.success_color
		if config.has("success_border_color"): success_border_color = config.success_border_color
		if config.has("info_color"): info_color = config.info_color
		if config.has("info_border_color"): info_border_color = config.info_border_color
		if config.has("warning_color"): warning_color = config.warning_color
		if config.has("warning_border_color"): warning_border_color = config.warning_border_color
		if config.has("error_color"): error_color = config.error_color
		if config.has("error_border_color"): error_border_color = config.error_border_color
		if config.has("corner_radius"): box_rounding = config.corner_radius
		if config.has("border_width_bottom"): border_width_bottom = config.border_width_bottom
		if config.has("border_width_left"): border_width_left = config.border_width_left

	message_label.text = msg
	severity = sev
	apply_style(sev)
	apply_animations(sev)
	error_close_button.pressed.connect(_on_close_pressed)
	if auto_dismiss:
		auto_dismiss_timer = Timer.new()
		auto_dismiss_timer.one_shot = true
		auto_dismiss_timer.timeout.connect(slide_closed)
		add_child(auto_dismiss_timer)
		auto_dismiss_timer.start(get_dismiss_time(sev))


## Animates the panel sliding into view. ERROR panels also shake after opening.
func slide_open() -> void:
	await animator.slide_open()
	if severity == ButteredSausageDisplay.Severity.ERROR:
		animator.shake()
		
		
## Closes the panel, optionally with a slide-out animation, then frees it from memory.[br][br]
##
## @param slide - If true, animates the panel sliding out before closing
func close(slide: bool = false) -> void:
	if is_closing:
		return
	is_closing = true
	if auto_dismiss_timer and auto_dismiss_timer.time_left > 0:
		auto_dismiss_timer.stop()
	if slide:
		await animator.slide_close()
	queue_free()

## Closes the panel with a slide-out animation.
func slide_closed() -> void:
	close(true)
	
	
func _on_close_pressed() -> void:
	slide_closed()
