@tool
## A toast notification panel that composes PanelBase and TextBase.[br]
## Adds icon, close button, auto-dismiss timer, severity styling, and hover-to-pause.[br][br]
##
## Created and managed by ButteredSausageToastDisplay.
class_name ButteredSausageToastPanel
extends ButteredSausagePanelBase

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

@export_group("Text Alignment")
@export var label_text_alignment: ButteredSausageTextBase.Alignment = ButteredSausageTextBase.Alignment.Center  ## Horizontal alignment for message text within the panel.

@export_group("Font")
@export var font: Font  ## Custom font resource for message text. Leave empty to use default theme font.
@export var font_color: Color = Color(1.0, 1.0, 1.0, 1.0)  ## Color of the message text. Remains constant during color animations.
@export var font_size: int = 12  ## Size of the message text in pixels.

@export_group("Text Animation Chains")
@export var text_entrance_animation_chain: Array[ButteredSausageTextStep] = []  ## Text animation steps played when panel opens. Forwarded to the message label.
@export var text_exit_animation_chain: Array[ButteredSausageTextStep] = []  ## Text animation steps for closing. Forwarded to the message label.
@export var text_close_behavior: ButteredSausagePanelBase.CloseBehavior = CloseBehavior.REVERSE_FIRST_ANIMATION  ## How to animate text closing when text_exit_animation_chain is empty.

@export_group("Auto-Dismiss Timing")
@export var auto_dismiss: bool = true  ## If true, panel automatically closes after duration seconds. If false, panel stays until manually closed.
@export var duration: float = 3.0  ## How long in seconds before the panel auto-dismisses. Timer pauses when mouse hovers over panel.

@export_group("Severity")
@export var severity: SSDMSeverity.Level = SSDMSeverity.Level.SUCCESS  ## Severity level this config applies to (SUCCESS, INFO, WARNING, or ERROR). Used for caching styleboxes and priority sorting.

@export_group("Control")
@export var icon_texture_control: Control
@export var icon_texture_rect: TextureRect
@export var message_label: ButteredSausageTextBase
@export var close_button_control: Control
@export var close_button: Button

var auto_dismiss_timer: Timer
var timer_paused: bool = false
var paused_time_left: float = 0.0
static var cached_styles: Dictionary = {}


## Applies toast-specific configuration on top of base panel styling.[br]
## Configures severity stylebox, icon, close button, and text styling.[br][br]
func configure() -> void:
	super.configure()

	# Apply severity-cached stylebox
	var sev: SSDMSeverity.Level = severity
	if !cached_styles.has(sev):
		cached_styles[sev] = create_stylebox()
	panel_container.add_theme_stylebox_override(PANEL_THEME, cached_styles[sev])

	# Forward text properties to message_label
	message_label.label_text_alignment = label_text_alignment
	message_label.font = font
	message_label.font_color = font_color
	message_label.font_size = font_size
	message_label.entrance_animation_chain = text_entrance_animation_chain
	message_label.exit_animation_chain = text_exit_animation_chain
	message_label.close_behavior = text_close_behavior
	message_label.configure()

	# Configure icon
	if hide_icon:
		icon_texture_rect.hide()
	else:
		icon_texture_rect.texture = icon
		icon_texture_rect.modulate = icon_modulate
	icon_texture_control.custom_minimum_size.x = icon_width
	icon_texture_control.custom_minimum_size.y = icon_height
	icon_texture_rect.custom_minimum_size.x = icon_width
	icon_texture_rect.custom_minimum_size.y = icon_height

	# Configure close button
	if hide_close_button:
		close_button.hide()
	else:
		if close_button_text != "":
			close_button.text = close_button_text
			close_button.icon = null
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = close_button_modulate
			close_button.add_theme_stylebox_override("normal", button_style)
		else:
			close_button.icon = close_button_icon
			close_button.text = ""
			close_button.modulate = close_button_modulate
	close_button_control.custom_minimum_size.x = close_button_width
	close_button_control.custom_minimum_size.y = close_button_height
	close_button.custom_minimum_size.x = close_button_width
	close_button.custom_minimum_size.y = close_button_height

	# Set mouse filters so child controls don't interfere with hover detection
	icon_texture_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	close_button_control.mouse_filter = Control.MOUSE_FILTER_PASS


## Initializes the toast panel with message and starts auto-dismiss timer.[br][br]
##
## @param msg - The message text to display[br]
func setup(msg: String) -> void:
	message_label.text = msg
	configure()

	if auto_dismiss:
		auto_dismiss_timer = Timer.new()
		auto_dismiss_timer.one_shot = true
		auto_dismiss_timer.timeout.connect(_on_auto_dismiss_timeout)
		add_child(auto_dismiss_timer)
		auto_dismiss_timer.start(duration)


## Opens the toast panel with panel entrance animation and text animation.[br][br]
func open() -> void:
	super.open()
	message_label.start()


## Dismisses the toast panel, optionally with animation, then frees it.[br][br]
##
## @param animate - If true, animates closing before freeing[br]
func dismiss(animate: bool = true) -> void:
	if is_closing:
		return
	is_closing = true

	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer):
		auto_dismiss_timer.stop()
		timer_paused = false

	if animate:
		message_label.close(true)
		await slide_closed()

	queue_free()


## Skips any active text animation (typewriter, apparate).[br][br]
func skip() -> void:
	message_label.skip()


func _on_auto_dismiss_timeout() -> void:
	dismiss(true)


func _on_close_pressed() -> void:
	dismiss(true)


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip()


func _on_mouse_entered() -> void:
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and not timer_paused:
		if auto_dismiss_timer.time_left > 0:
			paused_time_left = auto_dismiss_timer.time_left
			auto_dismiss_timer.stop()
			timer_paused = true


func _on_mouse_exited() -> void:
	if auto_dismiss_timer and is_instance_valid(auto_dismiss_timer) and timer_paused:
		auto_dismiss_timer.start(paused_time_left)
		timer_paused = false


func _ready() -> void:
	panel_container.mouse_entered.connect(_on_mouse_entered)
	panel_container.mouse_exited.connect(_on_mouse_exited)
	panel_container.gui_input.connect(_on_panel_gui_input)
