@tool
## An individual message panel that displays within SSDMErrorDisplay with animated entrance/exit.[br]
## Handles message display, auto-dismiss timers, and severity-based styling and animations.
class_name ButteredSausagePanel
extends Control

const PANEL_THEME: String = "panel"

@export var panel_container: PanelContainer
@export var margin_container: MarginContainer
@export var icon_texture_rect: TextureRect
@export var message_label: RichTextLabel
@export var close_button: Button

var panel_config: ButteredSausagePanelConfig
var severity: int
var animator: ButteredSausageAnimator
var is_closing: bool = false
var auto_dismiss_timer: Timer
static var cached_styles: Dictionary = {}


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
	pass
	"""animator = ButteredSausageAnimator.new(self, panel_container, buttered_sausage_config)
	match severity:
		ButteredSausageDisplay.Severity.SUCCESS:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE, buttered_sausage_config) \
				.with_speed(0.4) \
				.with_fade() 
		ButteredSausageDisplay.Severity.INFO:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE, buttered_sausage_config) \
				.with_speed(0.4)
		ButteredSausageDisplay.Severity.WARNING:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE, buttered_sausage_config) \
				.with_speed(1.4)
		ButteredSausageDisplay.Severity.ERROR:
			animator.configure(ButteredSausageAnimator.Axis.VERTICAL, ButteredSausageAnimator.OpenDirection.POSITIVE, buttered_sausage_config) \
				.with_scale(Vector2(0.3, 1)) \
				.with_rotation_pivot_center() \
				.with_rotation(0, 360)"""
	
		
func configure() -> void:
	var severity: ButteredSausageDisplay.Severity = panel_config.severity
	if !cached_styles.has(severity):
		var style_box = panel_config.create_stylebox()
		cached_styles[severity] = style_box
	panel_container.add_theme_stylebox_override(PANEL_THEME, cached_styles[severity])
	if panel_config.font:
		message_label.add_theme_font_override("normal_font", panel_config.font)
	message_label.add_theme_color_override("normal_font", panel_config.font_color)
	message_label.add_theme_font_size_override("normal_font", panel_config.font_size)
	if panel_config.hide_icon:
		icon_texture_rect.hide()
	else:
		icon_texture_rect.texture = panel_config.icon
	if panel_config.hide_close_button:
		close_button.hide()
	else:
		close_button.icon = panel_config.close_button_icon
	margin_container.add_theme_constant_override("margin_left", panel_config.margin_left)
	margin_container.add_theme_constant_override("margin_top", panel_config.margin_top)
	margin_container.add_theme_constant_override("margin_right", panel_config.margin_right)
	margin_container.add_theme_constant_override("margin_bottom", panel_config.margin_bottom)			
	
"""## Applies severity-specific background color to the panel.[br][br]
##
## @param sev - The severity level determining the panel color
func apply_style(sev: int) -> void:
	if not cached_styles.has(sev):
		var style_box = StyleBoxFlat.new()
		style_box.corner_radius_top_left = config.corner_radius
		style_box.corner_radius_top_right = config.corner_radius
		style_box.corner_radius_bottom_left = config.corner_radius
		style_box.corner_radius_bottom_right = config.corner_radius
		style_box.border_width_bottom = config.border_width_bottom
		style_box.border_width_left = config.border_width_left
		cached_styles[sev] = style_box
		match sev:
			ButteredSausageDisplay.Severity.SUCCESS:
				style_box.bg_color = config.success_color
				style_box.border_color = config.success_border_color
			ButteredSausageDisplay.Severity.INFO:
				style_box.bg_color = config.info_color
				style_box.border_color = config.info_border_color
			ButteredSausageDisplay.Severity.WARNING:
				style_box.bg_color = config.warning_color
				style_box.border_color = config.warning_border_color
			ButteredSausageDisplay.Severity.ERROR:
				style_box.bg_color = config.error_color
				style_box.border_color = config.error_border_color
	panel_container.add_theme_stylebox_override(PANEL_THEME, cached_styles[sev])"""
	
	
## Returns the auto-dismiss timeout duration based on severity.[br]
## Default: SUCCESS: 3s, WARNING: 4s, INFO: 6s, ERROR: 6s[br][br]
##
## @param sev - The severity level[br]
## @return The timeout duration in seconds
func get_dismiss_time(sev: int) -> float:
	match sev:
		ButteredSausageDisplay.Severity.SUCCESS:
			return panel_config.duration
		ButteredSausageDisplay.Severity.WARNING:
			return panel_config.duration
		ButteredSausageDisplay.Severity.INFO:
			return panel_config.duration
		ButteredSausageDisplay.Severity.ERROR:
			return panel_config.duration
		_:
			return panel_config.duration
	
	
## Initializes the panel with message, severity, styling, animations, and auto-dismiss timer.[br][br]
##
## @param msg - The message text to display[br]
## @param sev - The severity level[br]
## @param auto_dismiss - If true, panel will auto-close after a timeout[br]
## @param config - Optional configuration dictionary with colors, timings, and styling
func setup(msg: String, sev: int, config: ButteredSausagePanelConfig, auto_dismiss: bool = false) -> void:
	message_label.text = msg
	severity = sev
	panel_config = config
	configure()
	apply_animations(sev)
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
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and auto_dismiss_timer.time_left > 0:
		auto_dismiss_timer.stop()
	if slide:
		await animator.slide_close()
	queue_free()

## Closes the panel with a slide-out animation.
func slide_closed() -> void:
	close(true)
	
	
func _on_close_pressed() -> void:
	slide_closed()
