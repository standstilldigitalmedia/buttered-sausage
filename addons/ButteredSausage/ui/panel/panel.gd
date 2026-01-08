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
var animator: ButteredSausageAnimator
var is_closing: bool = false
var auto_dismiss_timer: Timer
static var cached_styles: Dictionary = {}


## Updates the displayed message text without creating a new panel.[br][br]
##
## @param message - The new message text to display
func update_message(message: String) -> void:
	message_label.text = message
	
	
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


## Animates the panel into view using the configured animation chain with optional looping.
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
		animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
		await animator.play()

	# Loop only animations marked for looping
	if has_looping_animations:
		while not is_closing:
			for anim_config in panel_config.animation_chain:
				if not anim_config.loop_animation:
					continue  # Skip animations not marked for looping
				animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
				await animator.play()
				if is_closing:
					break  # Exit immediately if panel is closing
		
		
## Closes the panel, optionally with animation, then frees it from memory.[br][br]
##
## @param animate - If true, animates the panel closing before freeing
func close(animate: bool = false) -> void:
	if is_closing:
		return
	is_closing = true
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and auto_dismiss_timer.time_left > 0:
		auto_dismiss_timer.stop()
	if animate:
		await slide_closed()
	queue_free()

## Animates the panel closing based on configuration.[br]
## Priority: 1) close_animation_chain, 2) mirror full open chain, 3) reverse first animation
func slide_closed() -> void:
	# If no animations configured at all, just hide
	if panel_config.animation_chain.is_empty():
		panel_container.hide()
		return

	# Priority 1: Use custom close animation chain if provided
	if not panel_config.close_animation_chain.is_empty():
		for anim_config in panel_config.close_animation_chain:
			animator = ButteredSausageAnimator.new(self, panel_container, anim_config)
			await animator.play()

	# Priority 2: Mirror the full open chain in reverse
	elif panel_config.mirror_full_open_chain_on_close:
		for i in range(panel_config.animation_chain.size() - 1, -1, -1):
			animator = ButteredSausageAnimator.new(self, panel_container, panel_config.animation_chain[i])
			await animator.reverse()

	# Priority 3: Default - reverse just the first animation
	else:
		animator = ButteredSausageAnimator.new(self, panel_container, panel_config.animation_chain[0])
		await animator.reverse()

	panel_container.hide()
	
	
## Called when auto-dismiss timer expires
func _on_auto_dismiss_timeout() -> void:
	close(true)


func _on_close_pressed() -> void:
	close(true)
