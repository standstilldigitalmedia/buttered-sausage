@tool
## Animates UI panels sliding in/out with optional scale, fade, rotation, bounce, and color effects.[br]
## Uses builder pattern for configuring animations. Created by passing wrapper and panel controls to constructor.
class_name ButteredSausageAnimator
extends RefCounted

enum Axis { VERTICAL, HORIZONTAL }
enum OpenDirection { POSITIVE, NEGATIVE }

const X_PROPERTY: String = "custom_minimum_size:x"
const Y_PROPERTY: String = "custom_minimum_size:y"
const SCALE_PROPERTY: String = "scale"
const MODULATE_A_PROPERTY: String = "modulate:a"
const MODULATE_PROPERTY: String = "modulate"
const ROTATION_PROPERTY: String = "rotation"
const POSITION_PROPERTY: String = "position"
const POSITION_X_PROPERTY: String = "position:x"

var wrapper: Control
var panel: Control
var slide_tween: Tween
var is_open: bool = false
var _monitoring: bool = false
var axis: Axis = Axis.VERTICAL
var open_direction: OpenDirection = OpenDirection.POSITIVE
var animate_scale: bool = false
var animate_fade: bool = false
var animate_rotation: bool = false
var animate_position: bool = false
var animate_color: bool = false
var scale_from: Vector2 = Vector2(0.9, 0.9)
var scale_to: Vector2 = Vector2.ONE
var fade_from: float = 0.0
var fade_to: float = 1.0
var rotation_from: float = 0.0
var rotation_to: float = 0.0
var position_offset: Vector2 = Vector2.ZERO
var color_from: Color = Color.WHITE
var color_to: Color = Color.WHITE
var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
var ease_type_open: Tween.EaseType = Tween.EASE_OUT
var ease_type_close: Tween.EaseType = Tween.EASE_IN
var animation_speed: float = 0.0
var rotation_pivot: Vector2 = Vector2.ZERO
var buttered_sausage_config: ButteredSausageConfig


## Configures the slide axis and open direction. Required before calling slide_open().[br][br]
##
## @param p_axis - VERTICAL for up/down slide, HORIZONTAL for left/right slide[br]
## @param p_open_direction - POSITIVE for down/right, NEGATIVE for up/left[br]
## @return This AWOCSlideAnimator instance for method chaining
func configure(p_axis: Axis, p_open_direction: OpenDirection, config: ButteredSausageConfig) -> ButteredSausageAnimator:
	axis = p_axis
	open_direction = p_open_direction
	buttered_sausage_config = config
	return self


## Adds scale animation to the slide. Panel scales from 'from' to 'to' during open.[br][br]
##
## @param from - Starting scale vector (default 0.9, 0.9)[br]
## @param to - Ending scale vector (default 1.0, 1.0)[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_scale(from: Vector2 = Vector2(0.9, 0.9), to: Vector2 = Vector2.ONE) -> ButteredSausageAnimator:
	animate_scale = true
	scale_from = from
	scale_to = to
	return self


## Adds fade animation to the slide. Panel fades from 'from' alpha to 'to' alpha during open.[br][br]
##
## @param from - Starting alpha value (default 0.0 = transparent)[br]
## @param to - Ending alpha value (default 1.0 = opaque)[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_fade(from: float = 0.0, to: float = 1.0) -> ButteredSausageAnimator:
	animate_fade = true
	fade_from = from
	fade_to = to
	return self


## Adds rotation animation to the slide. Panel rotates from 'from_degrees' to 'to_degrees' during open.[br]
## Rotates around top-left corner by default. Use with_rotation_pivot_*() methods to change pivot point.[br][br]
##
## @param from_degrees - Starting rotation in degrees[br]
## @param to_degrees - Ending rotation in degrees (default 0.0)[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation(from_degrees: float, to_degrees: float = 0.0) -> ButteredSausageAnimator:
	animate_rotation = true
	rotation_from = deg_to_rad(from_degrees)
	rotation_to = deg_to_rad(to_degrees)
	return self


## Sets rotation pivot to the center of the panel for rotation animations.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation_pivot_center() -> ButteredSausageAnimator:
	rotation_pivot = Vector2(-1, -1)
	return self


## Sets rotation pivot to the top-right corner of the panel for rotation animations.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation_pivot_top_right() -> ButteredSausageAnimator:
	rotation_pivot = Vector2(-2, -2)
	return self


## Sets rotation pivot to the bottom-left corner of the panel for rotation animations.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation_pivot_bottom_left() -> ButteredSausageAnimator:
	rotation_pivot = Vector2(-3, -3)
	return self


## Sets rotation pivot to the bottom-right corner of the panel for rotation animations.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation_pivot_bottom_right() -> ButteredSausageAnimator:
	rotation_pivot = Vector2(-4, -4)
	return self


## Sets a custom rotation pivot offset for rotation animations.[br][br]
##
## @param offset - Custom pivot offset in pixels from top-left corner[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_rotation_pivot_custom(offset: Vector2) -> ButteredSausageAnimator:
	rotation_pivot = offset
	return self


## Adds color tint animation to the slide. Panel modulates from 'from_color' to 'to_color' during open.[br][br]
##
## @param from_color - Starting color tint[br]
## @param to_color - Ending color tint (default Color.WHITE)[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_color_tint(from_color: Color, to_color: Color = Color.WHITE) -> ButteredSausageAnimator:
	animate_color = true
	color_from = from_color
	color_to = to_color
	return self


## Adds position offset animation to the slide. Panel starts at 'offset' and moves to Vector2.ZERO.[br][br]
##
## @param offset - Starting position offset from final position[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_position_offset(offset: Vector2) -> ButteredSausageAnimator:
	animate_position = true
	position_offset = offset
	return self


## Sets transition type to TRANS_BACK for a bounce effect.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_bounce() -> ButteredSausageAnimator:
	transition_type = Tween.TRANS_BACK
	return self


## Sets transition type to TRANS_ELASTIC for an elastic spring effect.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_elastic() -> ButteredSausageAnimator:
	transition_type = Tween.TRANS_ELASTIC
	return self


## Sets transition type to TRANS_SPRING for a spring physics effect.[br][br]
##
## @return This AWOCSlideAnimator instance for method chaining
func with_spring() -> ButteredSausageAnimator:
	transition_type = Tween.TRANS_SPRING
	return self


## Sets custom animation speed in seconds. If not set, uses default SLIDE_SPEED (0.3s).[br][br]
##
## @param speed - Animation duration in seconds[br]
## @return This AWOCSlideAnimator instance for method chaining
func with_speed(speed: float) -> ButteredSausageAnimator:
	animation_speed = speed
	return self


## Animates the panel sliding into view with all configured effects. Starts monitoring panel size changes.
func slide_open() -> void:
	if not wrapper or not panel:
		push_error("ButteredSausageAnimator: wrapper or panel is null")
		return
	if slide_tween:
		slide_tween.kill()
	var property_name: String
	var target_size: float
	var anim_speed: float = animation_speed if animation_speed > 0 else buttered_sausage_config.slide_speed
	if axis == Axis.VERTICAL:
		property_name = Y_PROPERTY
		target_size = panel.get_combined_minimum_size().y
		if open_direction == OpenDirection.POSITIVE:
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		else:
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_END
		wrapper.custom_minimum_size.y = 0
	else: 
		property_name = X_PROPERTY
		target_size = buttered_sausage_config.panel_width
		if open_direction == OpenDirection.POSITIVE:
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		else:
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_END
		wrapper.custom_minimum_size.x = 0
	if animate_scale:
		panel.scale = scale_from
	if animate_rotation:
		panel.rotation = rotation_from
		if rotation_pivot == Vector2(-1, -1):
			panel.pivot_offset = panel.size / 2
		elif rotation_pivot == Vector2(-2, -2):
			panel.pivot_offset = Vector2(panel.size.x, 0)
		elif rotation_pivot == Vector2(-3, -3):
			panel.pivot_offset = Vector2(0, panel.size.y)
		elif rotation_pivot == Vector2(-4, -4):
			panel.pivot_offset = panel.size
		elif rotation_pivot != Vector2.ZERO:
			panel.pivot_offset = rotation_pivot
	if animate_position:
		panel.position = position_offset
	if animate_color:
		wrapper.modulate = color_from
	elif animate_fade:
		wrapper.modulate.a = fade_from
	wrapper.show()
	await wrapper.get_tree().process_frame
	if axis == Axis.VERTICAL:
		target_size = panel.get_combined_minimum_size().y
	else:
		target_size = buttered_sausage_config.panel_width
	var has_fancy_animations = animate_scale or animate_fade or animate_rotation or animate_position or animate_color
	slide_tween = wrapper.create_tween()
	slide_tween.set_parallel(has_fancy_animations)
	slide_tween.set_ease(ease_type_open)
	slide_tween.set_trans(transition_type)
	slide_tween.tween_property(wrapper, property_name, target_size, anim_speed).from(0)
	if animate_scale:
		slide_tween.tween_property(panel, SCALE_PROPERTY, scale_to, anim_speed)
	if animate_rotation:
		slide_tween.tween_property(panel, ROTATION_PROPERTY, rotation_to, anim_speed)
	if animate_position:
		slide_tween.tween_property(panel, POSITION_PROPERTY, Vector2.ZERO, anim_speed)
	if animate_color:
		slide_tween.tween_property(wrapper, MODULATE_PROPERTY, color_to, anim_speed)
	elif animate_fade:
		slide_tween.tween_property(wrapper, MODULATE_A_PROPERTY, fade_to, anim_speed * 0.75)
	await slide_tween.finished
	is_open = true
	start_monitoring()


## Animates the panel sliding out of view, reversing all configured effects. Stops monitoring and resets states.
func slide_close() -> void:
	if not wrapper or not panel:
		return
	stop_monitoring()
	is_open = false
	if slide_tween:
		slide_tween.kill()
	if not wrapper.visible:
		return
	var property_name: String
	var current_size: float
	var anim_speed: float = animation_speed if animation_speed > 0 else buttered_sausage_config.slide_speed
	if axis == Axis.VERTICAL:
		property_name = Y_PROPERTY
		current_size = wrapper.custom_minimum_size.y if wrapper.custom_minimum_size.y > 0 else wrapper.size.y
		wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
	else:
		property_name = X_PROPERTY
		current_size = wrapper.custom_minimum_size.x if wrapper.custom_minimum_size.x > 0 else wrapper.size.x
		wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
	var has_fancy_animations = animate_scale or animate_fade or animate_rotation or animate_position or animate_color
	slide_tween = wrapper.create_tween()
	slide_tween.set_parallel(has_fancy_animations)
	slide_tween.set_ease(ease_type_close)
	slide_tween.set_trans(transition_type if has_fancy_animations else Tween.TRANS_CUBIC)
	slide_tween.tween_property(wrapper, property_name, 0, anim_speed).from(current_size)
	if animate_scale:
		slide_tween.tween_property(panel, SCALE_PROPERTY, scale_from, anim_speed)
	if animate_rotation:
		slide_tween.tween_property(wrapper, ROTATION_PROPERTY, rotation_from, anim_speed)
	if animate_position:
		slide_tween.tween_property(wrapper, POSITION_PROPERTY, position_offset, anim_speed)
	if animate_color:
		slide_tween.tween_property(wrapper, MODULATE_PROPERTY, color_from, anim_speed)
	elif animate_fade:
		slide_tween.tween_property(wrapper, MODULATE_A_PROPERTY, fade_from, anim_speed)
	await slide_tween.finished
	wrapper.hide()
	if axis == Axis.VERTICAL:
		wrapper.custom_minimum_size.y = 0
	else:
		wrapper.custom_minimum_size.x = 0
	if animate_scale:
		panel.scale = Vector2.ONE
	if animate_rotation:
		wrapper.rotation = 0.0
	if animate_position:
		wrapper.position = Vector2.ZERO
	if animate_color:
		wrapper.modulate = Color.WHITE
	elif animate_fade:
		wrapper.modulate.a = 1.0


## Immediately closes the panel without animation. Stops monitoring and resets all animation states.
func close_immediate() -> void:
	stop_monitoring()
	is_open = false
	if slide_tween:
		slide_tween.kill()
	if wrapper:
		wrapper.hide()
		if axis == Axis.VERTICAL:
			wrapper.custom_minimum_size.y = 0
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		else:
			wrapper.custom_minimum_size.x = 0
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		if animate_scale:
			panel.scale = Vector2.ONE
		if animate_rotation:
			wrapper.rotation = 0.0
		if animate_position:
			wrapper.position = Vector2.ZERO
		if animate_color:
			wrapper.modulate = Color.WHITE
		elif animate_fade:
			wrapper.modulate.a = 1.0


## Shakes the panel horizontally with decreasing intensity. Useful for error emphasis.[br][br]
##
## @param shake_amount - Maximum horizontal shake distance in pixels (default 3.0)[br]
## @param shake_speed - Duration of each shake movement in seconds (default 0.05)
func shake(shake_amount: float = 3.0, shake_speed: float = 0.05) -> void:
	if not wrapper or not wrapper.visible:
		return
	var shake_tween = wrapper.create_tween()
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, shake_amount, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, -shake_amount, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, shake_amount / 2.0, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, 0, shake_speed)


## Starts monitoring panel size changes to automatically update wrapper size when panel content changes.
func start_monitoring() -> void:
	if _monitoring or not panel:
		return
	if not panel.minimum_size_changed.is_connected(_on_panel_size_changed):
		panel.minimum_size_changed.connect(_on_panel_size_changed)
		_monitoring = true


## Stops monitoring panel size changes and disconnects the size_changed signal.
func stop_monitoring() -> void:
	if not _monitoring or not panel:
		return
	if panel.minimum_size_changed.is_connected(_on_panel_size_changed):
		panel.minimum_size_changed.disconnect(_on_panel_size_changed)
	_monitoring = false


func _on_panel_size_changed() -> void:
	if not is_open or not wrapper or not wrapper.visible or not panel:
		return
	if axis == Axis.VERTICAL:
		var new_height = panel.get_combined_minimum_size().y
		if abs(wrapper.custom_minimum_size.y - new_height) > 1.0:
			wrapper.custom_minimum_size.y = new_height
	else:
		var new_width = panel.get_combined_minimum_size().x
		if abs(wrapper.custom_minimum_size.x - new_width) > 1.0:
			wrapper.custom_minimum_size.x = new_width
		
		
func _init(panel_wrapper: Control, panel_container: Control, config: ButteredSausageConfig) -> void:
	wrapper = panel_wrapper
	panel = panel_container
	buttered_sausage_config = config
