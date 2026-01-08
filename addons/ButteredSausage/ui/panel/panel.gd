@tool
## An individual message panel that displays within ButteredSausageDisplay.[br]
## Handles message display, auto-dismiss timers with hover-to-pause, severity-based styling, and animations.[br][br]
##
## Created and managed by ButteredSausageDisplay.
class_name ButteredSausagePanel
extends Control

const PANEL_THEME: String = "panel"

@export var panel_container: PanelContainer
@export var margin_container: MarginContainer
@export var icon_texture_control: Control
@export var icon_texture_rect: TextureRect
@export var message_label: RichTextLabel
@export var close_button_control: Control
@export var close_button: Button

var panel_config: ButteredSausagePanelConfig
var is_closing: bool = false
var auto_dismiss_timer: Timer
var timer_paused: bool = false
var paused_time_left: float = 0.0
static var cached_styles: Dictionary = {}


## Updates the displayed message text without creating a new panel.[br][br]
##
## @param message - The new message text to display[br]
func update_message(message: String) -> void:
	message_label.text = message


## Applies the panel configuration to all UI elements.[br]
## Sets styling, fonts, colors, icons, margins, and mouse filters.[br][br]
func configure() -> void:
	var severity: ButteredSausageSeverity.Level = panel_config.severity
	if !cached_styles.has(severity):
		var style_box = panel_config.create_stylebox()
		cached_styles[severity] = style_box
	panel_container.add_theme_stylebox_override(PANEL_THEME, cached_styles[severity])
	if panel_config.font:
		message_label.add_theme_font_override("normal_font", panel_config.font)
	message_label.add_theme_color_override("normal_font", panel_config.font_color)
	message_label.add_theme_font_size_override("normal_font", panel_config.font_size)
	message_label.horizontal_alignment = panel_config.label_text_alignment as int
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
	icon_texture_control.custom_minimum_size.x = panel_config.icon_width
	icon_texture_control.custom_minimum_size.y = panel_config.icon_height
	close_button_control.custom_minimum_size.x = panel_config.close_button_width
	close_button_control.custom_minimum_size.y = panel_config.close_button_height
	
	icon_texture_rect.custom_minimum_size.x = panel_config.icon_width
	icon_texture_rect.custom_minimum_size.y = panel_config.icon_height
	close_button.custom_minimum_size.x = panel_config.close_button_width
	close_button.custom_minimum_size.y = panel_config.close_button_height

	# Set mouse filters so child controls don't interfere with hover detection
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_texture_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	close_button_control.mouse_filter = Control.MOUSE_FILTER_PASS
	# Note: close_button itself needs MOUSE_FILTER_STOP to remain clickable

## Initializes the panel with message, styling, and auto-dismiss timer.[br][br]
##
## @param msg - The message text to display[br]
## @param config - Panel configuration resource
func setup(msg: String, config: ButteredSausagePanelConfig) -> void:
	message_label.text = msg
	panel_config = config
	configure()

	# Start auto-dismiss timer immediately if enabled in config
	if panel_config.auto_dismiss:
		auto_dismiss_timer = Timer.new()
		auto_dismiss_timer.one_shot = true
		auto_dismiss_timer.timeout.connect(_on_auto_dismiss_timeout)
		add_child(auto_dismiss_timer)
		auto_dismiss_timer.start(panel_config.duration)


## Animates the panel into view using the configured animation chain.[br]
## Supports optional animation looping until panel closes.[br][br]
func slide_open() -> void:
	# If no animations configured, just show panel
	if panel_config.animation_chain.is_empty():
		panel_container.show()
		return

	# Play entire animation chain once and detect if any want to loop
	var has_looping_animations: bool = false
	for anim_config in panel_config.animation_chain:
		if anim_config.loop_animation:
			has_looping_animations = true
		if anim_config.animate_color:
			var stylebox = StyleBoxFlat.new()
			stylebox.bg_color = Color(1.0, 1.0, 1.0, 1.0)
			panel_container.add_theme_stylebox_override(PANEL_THEME, stylebox)
		var animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
		await animator.play()

	# Loop only animations marked for looping
	if has_looping_animations:
		while not is_closing:
			for anim_config in panel_config.animation_chain:
				if not anim_config.loop_animation:
					continue  # Skip animations not marked for looping
				var animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
				await animator.play()
				if is_closing:
					break  # Exit immediately if panel is closing
		

## Animates the panel closing based on configuration.[br]
## Priority: 1) close_animation_chain (if provided), 2) close_behavior setting
func slide_closed() -> void:
	# Priority 1: Use custom close animation chain if provided
	if not panel_config.close_animation_chain.is_empty():
		for anim_config in panel_config.close_animation_chain:
			var animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
			await animator.play()
		panel_container.hide()
		return

	# Priority 2: Use close_behavior setting
	match panel_config.close_behavior:
		ButteredSausagePanelConfig.CloseBehavior.NO_ANIMATION:
			# Just hide immediately
			panel_container.hide()

		ButteredSausagePanelConfig.CloseBehavior.MIRROR_FULL_CHAIN:
			# Reverse entire animation chain in reverse order
			if panel_config.animation_chain.is_empty():
				panel_container.hide()
			else:
				for i in range(panel_config.animation_chain.size() - 1, -1, -1):
					var animator = ButteredSausageAnimator.new(self, panel_container, panel_config.animation_chain[i])
					await animator.reverse()
				panel_container.hide()

		ButteredSausagePanelConfig.CloseBehavior.REVERSE_FIRST_ANIMATION:
			# Default - reverse just the first animation
			if panel_config.animation_chain.is_empty():
				panel_container.hide()
			else:
				var animator = ButteredSausageAnimator.new(self, panel_container, panel_config.animation_chain[0])
				await animator.reverse()
				panel_container.hide()
				
					
## Closes the panel, optionally with animation, then frees it from memory.[br][br]
##
## @param animate - If true, animates the panel closing before freeing
func close(animate: bool = false) -> void:
	if is_closing:
		return
	is_closing = true
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer):
		auto_dismiss_timer.stop()
		timer_paused = false
	if animate:
		await slide_closed()
	queue_free()


## Called when auto-dismiss timer expires.[br]
## Closes the panel with animation.[br][br]
func _on_auto_dismiss_timeout() -> void:
	close(true)


## Called when close button is pressed.[br]
## Closes the panel with animation.[br][br]
func _on_close_pressed() -> void:
	close(true)


## Pauses the auto-dismiss timer when mouse hovers over the panel.[br][br]
func _on_mouse_entered() -> void:
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and not timer_paused:
		if auto_dismiss_timer.time_left > 0:
			paused_time_left = auto_dismiss_timer.time_left
			auto_dismiss_timer.stop()
			timer_paused = true


## Resumes the auto-dismiss timer when mouse leaves the panel.[br][br]
func _on_mouse_exited() -> void:
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and timer_paused:
		auto_dismiss_timer.start(paused_time_left)
		timer_paused = false


## Connects mouse hover signals for pause/resume functionality.[br][br]
func _ready() -> void:
	panel_container.mouse_entered.connect(_on_mouse_entered)
	panel_container.mouse_exited.connect(_on_mouse_exited)
