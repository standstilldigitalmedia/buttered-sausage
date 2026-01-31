@tool
## An individual message panel that displays within ButteredSausageDisplay.[br]
## Handles message display, auto-dismiss timers with hover-to-pause, severity-based styling, and animations.[br][br]
##
## Created and managed by ButteredSausageDisplay.
class_name ButteredSausagePanelBase
extends Control

const PANEL_THEME: String = "panel"

enum Axis {
	VERTICAL,    ## Animation moves vertically (up/down direction)
	HORIZONTAL   ## Animation moves horizontally (left/right direction)
}

enum OpenDirection {
	POSITIVE,    ## Move in positive direction (down for vertical, right for horizontal)
	NEGATIVE     ## Move in negative direction (up for vertical, left for horizontal)
}

enum AnchorPresets {
	TopLeft,       ## Anchor panel to top-left position
	TopCenter,     ## Anchor panel to top-center position
	TopRight,      ## Anchor panel to top-right position
	CenterLeft,    ## Anchor panel to center-left position
	Center,        ## Anchor panel to exact center position
	CenterRight,   ## Anchor panel to center-right position
	BottomLeft,    ## Anchor panel to bottom-left position
	BottomCenter,  ## Anchor panel to bottom-center position
	BottomRight    ## Anchor panel to bottom-right position
}

enum Alignment {
	Left,     ## Align message text to the left edge of the panel
	Center,   ## Center message text within the panel (default, most common)
	Right,    ## Align message text to the right edge of the panel
	Justify   ## Stretch text to fill the width of the panel
}

enum CloseBehavior {
	REVERSE_FIRST_ANIMATION,  ## Play only the first animation from entrance_animation_chain in reverse when closing. Quick and clean.
	MIRROR_FULL_CHAIN,        ## Play all animations from entrance_animation_chain in reverse order when closing. Symmetrical open/close.
	NO_ANIMATION              ## Panel disappears instantly without any closing animation. Use for urgent dismissals.
}

@export_group("Background Color")
@export var background_color: Color = Color(0.2, 0.6, 0.2, 0.9)  ## Main background color for the panel. Color animations will tween this value if enabled.

@export_group("Text Alignment")
@export var label_text_alignment: Alignment = Alignment.Center  ## Horizontal alignment for message text within the panel (Left, Center, Right, or Justify).

@export_group("Font")
@export var font: Font  ## Custom font resource for message text. Leave empty to use default theme font.
@export var font_color: Color = Color(0.0, 0.0, 0.0, 1.0)  ## Color of the message text. Remains constant during color animations.
@export var font_size: int = 12  ## Size of the message text in pixels.

@export_group("Icon")
@export var hide_icon: bool = false  ## If true, no icon is displayed on the panel. If false, shows the icon texture on the left side.
@export var icon: Texture2D  ## Texture displayed as an icon on the left side of the panel (e.g., checkmark for success, X for error).
@export var icon_modulate: Color = Color.WHITE  ## Color modulation applied to the icon. Use to tint or colorize the icon texture.
@export var icon_width: float = 24  ## Width of the icon display area in pixels.
@export var icon_height: float = 24  ## Height of the icon display area in pixels.

@export_group("Close Button")
@export var hide_close_button: bool = false  ## If true, removes the manual close button. Panel can only be dismissed via auto-dismiss timer.
@export var close_button_text: String = ""  ## If set, shows text instead of icon for close button (e.g., "X" or "Close").
@export var close_button_icon: Texture2D  ## Texture for the close button (typically an X icon). Appears on the right side of the panel.
@export var close_button_modulate: Color = Color.WHITE  ## Color modulation applied to the close button icon or text background.
@export var close_button_width: float = 24  ## Width of the close button in pixels.
@export var close_button_height: float = 24  ## Height of the close button in pixels.

@export_group("Border")
@export var border_color: Color = Color(0.1, 0.5, 0.1, 0.9)  ## Color of the panel border on all sides.
@export var top_width: int = 0  ## Border thickness for the top edge in pixels. 0 = no border.
@export var left_width: int = 0  ## Border thickness for the left edge in pixels. 0 = no border.
@export var bottom_width: int = 5  ## Border thickness for the bottom edge in pixels. 0 = no border.
@export var right_width: int = 3  ## Border thickness for the right edge in pixels. 0 = no border.

@export_group("Corner Radius")
@export var top_left_corner_radius: int = 4  ## Roundness of the top-left corner in pixels. 0 = sharp corner, higher = more rounded.
@export var top_right_corner_radius: int = 4  ## Roundness of the top-right corner in pixels. 0 = sharp corner, higher = more rounded.
@export var bottom_left_corner_radius: int = 4  ## Roundness of the bottom-left corner in pixels. 0 = sharp corner, higher = more rounded.
@export var bottom_right_corner_radius: int = 4  ## Roundness of the bottom-right corner in pixels. 0 = sharp corner, higher = more rounded.

@export_group("Margins")
@export var margin_top: int = 5  ## Internal padding between panel edge and content at the top in pixels.
@export var margin_left: int = 5  ## Internal padding between panel edge and content on the left in pixels.
@export var margin_bottom: int = 5  ## Internal padding between panel edge and content at the bottom in pixels.
@export var margin_right: int = 5  ## Internal padding between panel edge and content on the right in pixels.

@export_group("Auto-Dismiss Timing")
@export var auto_dismiss: bool = true  ## If true, panel automatically closes after duration seconds. If false, panel stays until manually closed.
@export var duration: float = 3.0  ## How long in seconds before the panel auto-dismisses. Timer pauses when mouse hovers over panel.

@export_group("Animation Chains")
@export var entrance_animation_chain: Array[ButteredSausageAnimationStep] = []  ## Sequence of animation steps played when panel opens. Each step wraps an AnimatorConfig with optional reverse, loop, and delay. Leave empty for instant appearance.
@export var exit_animation_chain: Array[ButteredSausageAnimationStep] = []  ## Custom animation steps for closing. If empty, uses close_behavior instead.
@export var close_behavior: CloseBehavior = CloseBehavior.REVERSE_FIRST_ANIMATION  ## How to animate closing when exit_animation_chain is empty. Can reverse first animation, mirror full chain, or skip animation.

@export_group("Severity")
@export var severity: SSDMSeverity.Level = SSDMSeverity.Level.SUCCESS  ## Severity level this config applies to (SUCCESS, INFO, WARNING, or ERROR). Used for caching styleboxes and priority sorting.

@export_group("Control")
@export var rotation_container: Control
@export var panel_container: PanelContainer
@export var margin_container: MarginContainer
@export var icon_texture_control: Control
@export var icon_texture_rect: TextureRect
@export var message_label: RichTextLabel
@export var close_button_control: Control
@export var close_button: Button

var is_closing: bool = false
var auto_dismiss_timer: Timer
var timer_paused: bool = false
var paused_time_left: float = 0.0
var text_animator: ButteredSausageTextAnimator  # Cached animator for text effects and skip_on_click
static var cached_styles: Dictionary = {}


## Creates a StyleBoxFlat from the configured visual properties.[br][br]
##
## @return A StyleBoxFlat with configured colors, borders, and corner radii[br]
func create_stylebox() -> StyleBox:
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = background_color
	style_box.corner_radius_top_left = top_left_corner_radius
	style_box.corner_radius_top_right = top_right_corner_radius
	style_box.corner_radius_bottom_left = bottom_left_corner_radius
	style_box.corner_radius_bottom_right = bottom_right_corner_radius
	style_box.border_color = border_color
	style_box.border_width_top = top_width
	style_box.border_width_left = left_width
	style_box.border_width_bottom = bottom_width
	style_box.border_width_right = right_width
	return style_box
	
	
## Updates the displayed message text without creating a new panel.[br][br]
##
## @param message - The new message text to display[br]
func update_message(message: String) -> void:
	message_label.text = message


## Applies the panel configuration to all UI elements.[br]
## Sets styling, fonts, colors, icons, margins, and mouse filters.[br][br]
func configure() -> void:
	var sev: SSDMSeverity.Level = severity
	if !cached_styles.has(sev):
		var style_box = create_stylebox()
		cached_styles[sev] = style_box
	panel_container.add_theme_stylebox_override(PANEL_THEME, cached_styles[sev])
	if font:
		message_label.add_theme_font_override("normal_font", font)
	message_label.add_theme_color_override("default_color", font_color)
	message_label.add_theme_font_size_override("normal_font_size", font_size)
	message_label.horizontal_alignment = label_text_alignment as int
	if hide_icon:
		icon_texture_rect.hide()
	else:
		icon_texture_rect.texture = icon
		icon_texture_rect.modulate = icon_modulate
	if hide_close_button:
		close_button.hide()
	else:
		# Handle text vs icon mode
		if close_button_text != "":
			close_button.text = close_button_text
			close_button.icon = null
			# For text mode, set button background color
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = close_button_modulate
			close_button.add_theme_stylebox_override("normal", button_style)
		else:
			close_button.icon = close_button_icon
			close_button.text = ""
			# For icon mode, modulate the icon
			close_button.modulate = close_button_modulate
	margin_container.add_theme_constant_override("margin_left", margin_left)
	margin_container.add_theme_constant_override("margin_top", margin_top)
	margin_container.add_theme_constant_override("margin_right", margin_right)
	margin_container.add_theme_constant_override("margin_bottom", margin_bottom)
	icon_texture_control.custom_minimum_size.x = icon_width
	icon_texture_control.custom_minimum_size.y = icon_height
	close_button_control.custom_minimum_size.x = close_button_width
	close_button_control.custom_minimum_size.y = close_button_height
	
	icon_texture_rect.custom_minimum_size.x = icon_width
	icon_texture_rect.custom_minimum_size.y = icon_height
	close_button.custom_minimum_size.x = close_button_width
	close_button.custom_minimum_size.y = close_button_height

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
func setup(msg: String) -> void:
	message_label.text = msg
	configure()

	# Start auto-dismiss timer immediately if enabled in config
	if auto_dismiss:
		auto_dismiss_timer = Timer.new()
		auto_dismiss_timer.one_shot = true
		auto_dismiss_timer.timeout.connect(_on_auto_dismiss_timeout)
		add_child(auto_dismiss_timer)
		auto_dismiss_timer.start(duration)


## Animates the panel into view using the configured animation chain.[br]
## Supports optional animation looping until panel closes.[br][br]
func slide_open() -> void:
	# If no animations configured, just show panel without animation
	if entrance_animation_chain.is_empty():
		panel_container.show()
		show()
		# Need to wait for layout to calculate panel size
		await get_tree().process_frame
		# Set wrapper size to match panel content
		custom_minimum_size.y = panel_container.get_combined_minimum_size().y
		size_flags_vertical = 0  # Shrink to beginning
		return

	# Play entire animation chain once and detect if any want to loop
	var has_looping_animations: bool = false
	var is_first_step: bool = true
	for step in entrance_animation_chain:
		# Skip steps with no animations assigned
		if not step.panel_animation and not step.text_animation:
			continue

		if step.panel_loop:
			has_looping_animations = true

		# Apply delay before this step
		if step.delay_before > 0.0:
			await get_tree().create_timer(step.delay_before).timeout
			if is_closing:
				break

		# Handle color animation stylebox setup (only for forward animations)
		# Reversed animations should start from the current color, not reset to color_from
		if step.panel_animation and step.panel_animation.animate_color and not step.panel_reverse:
			# Create a stylebox with all the configured styling (corners, borders, etc.)
			# Animator will tween the bg_color property directly
			var stylebox = create_stylebox()
			stylebox.bg_color = step.panel_animation.color_from
			panel_container.add_theme_stylebox_override(PANEL_THEME, stylebox)

		# Create animators for this step
		var panel_anim: ButteredSausagePanelAnimator = null
		var text_anim: ButteredSausageTextAnimator = null

		if step.panel_animation:
			panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
			panel_anim.configure(step.panel_animation)

		# Text animations only run on first step
		if step.text_animation and is_first_step:
			text_anim = ButteredSausageTextAnimator.new(message_label)
			text_anim.configure(step.text_animation)
			# Cache animator for skip_on_click
			if step.text_animation.animate_typewriter or step.text_animation.animate_text_apparate:
				text_animator = text_anim
				if step.text_animation.skip_on_click and not panel_container.gui_input.is_connected(_on_panel_gui_input):
					panel_container.gui_input.connect(_on_panel_gui_input)
			is_first_step = false

		# Play panel and text animations simultaneously
		# Start both without awaiting, then wait for both to finish
		if panel_anim:
			if step.panel_reverse:
				# For looping animations, don't hide after reverse (they need to stay visible for the loop)
				panel_anim.reverse(not step.panel_loop)
			else:
				panel_anim.play()

		if text_anim:
			if step.text_reverse:
				text_anim.reverse()
			else:
				text_anim.play(step.text_duration)

		# Wait for animations to complete
		# For text animations with duration=0 (infinite), don't wait - let them continue
		if panel_anim:
			await panel_anim.finished
		if text_anim and step.text_duration > 0:
			await text_anim.finished

		# Handle crawl layout adjustment
		if step.text_animation and step.text_animation.animate_text_crawl:
			custom_minimum_size.y = panel_container.get_combined_minimum_size().y

	# Loop only panel animations marked for looping
	if has_looping_animations:
		while not is_closing:
			for step in entrance_animation_chain:
				# Skip steps with no panel animation or not marked for looping
				if not step.panel_animation or not step.panel_loop:
					continue

				# Apply delay before this step
				if step.delay_before > 0.0:
					await get_tree().create_timer(step.delay_before).timeout
					if is_closing:
						break

				var panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
				panel_anim.configure(step.panel_animation)
				if step.panel_reverse:
					# Use hide_after=false for looping - don't hide the panel
					panel_anim.reverse(false)
				else:
					panel_anim.play()
				await panel_anim.finished
				if is_closing:
					break  # Exit immediately if panel is closing


## Animates the panel closing based on configuration.[br]
## Priority: 1) exit_animation_chain (if provided), 2) close_behavior setting
func slide_closed() -> void:
	# Priority 1: Use custom exit animation chain if provided
	if !exit_animation_chain.is_empty():
		for step in exit_animation_chain:
			# Skip steps with no panel animation assigned
			if !step.panel_animation:
				continue

			# Apply delay before this step
			if step.delay_before > 0.0:
				await get_tree().create_timer(step.delay_before).timeout

			var panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
			panel_anim.configure(step.panel_animation)
			# Use hide_after=false - we hide explicitly at the end
			if step.panel_reverse:
				panel_anim.reverse(false)
			else:
				panel_anim.play()
			await panel_anim.finished
		panel_container.hide()
		return

	# Priority 2: Use close_behavior setting
	match close_behavior:
		CloseBehavior.NO_ANIMATION:
			# Just hide immediately
			panel_container.hide()

		CloseBehavior.MIRROR_FULL_CHAIN:
			# Reverse entire animation chain in reverse order
			if entrance_animation_chain.is_empty():
				panel_container.hide()
			else:
				for i in range(entrance_animation_chain.size() - 1, -1, -1):
					var step = entrance_animation_chain[i]

					# Skip steps with no panel animation assigned
					if not step.panel_animation:
						continue

					# Apply delay before this step
					if step.delay_before > 0.0:
						await get_tree().create_timer(step.delay_before).timeout

					var panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
					panel_anim.configure(step.panel_animation)
					# Invert the reverse flag when mirroring
					# Use hide_after=false - we hide explicitly at the end
					if step.panel_reverse:
						panel_anim.play()
					else:
						panel_anim.reverse(false)
					await panel_anim.finished
				panel_container.hide()

		CloseBehavior.REVERSE_FIRST_ANIMATION:
			# Default - reverse just the first animation
			if entrance_animation_chain.is_empty():
				panel_container.hide()
			else:
				var step = entrance_animation_chain[0]

				# Only reverse if panel animation is assigned
				if step.panel_animation:
					# Apply delay before this step
					if step.delay_before > 0.0:
						await get_tree().create_timer(step.delay_before).timeout

					var panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
					panel_anim.configure(step.panel_animation)
					# Invert the reverse flag when reversing
					# Use hide_after=false - we hide explicitly at the end
					if step.panel_reverse:
						panel_anim.play()
					else:
						panel_anim.reverse(false)
					await panel_anim.finished
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


## Called when panel receives input. Used for skip_on_click functionality.[br][br]
func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if text_animator:
			text_animator.skip()


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
