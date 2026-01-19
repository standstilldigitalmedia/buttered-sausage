@tool
## Animates Control nodes with slide, scale, fade, rotation, position, color, and shake effects.[br]
## Can be used standalone to animate any Control node or integrated with ButteredSausagePanel.[br][br]
##
## Dependencies: ButteredSausageAnimatorConfig only.[br]
## Created by passing wrapper Control, panel Control, and configuration to constructor.
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
var rotation_container: Control  # Middle layer for rotation isolation
var slide_tween: Tween
var is_open: bool = false
var _monitoring: bool = false
var animator_config: ButteredSausageAnimatorConfig


## Configures the animator with animation parameters.[br][br]
##
## @param config - The animator configuration resource[br]
## @return This animator instance for method chaining[br]
func configure(config: ButteredSausageAnimatorConfig) -> ButteredSausageAnimator:
	animator_config = config
	return self


## Calculates the pivot offset for rotation based on the configured pivot preset.[br][br]
##
## @param node - The Control node to calculate pivot for[br]
## @return The pivot offset as a Vector2[br]
func _get_pivot_offset(node: Control) -> Vector2:
	match animator_config.rotation_pivot_preset:
		ButteredSausageAnimatorConfig.RotationPivot.TOP_LEFT:
			return Vector2.ZERO
		ButteredSausageAnimatorConfig.RotationPivot.TOP_CENTER:
			return Vector2(node.size.x / 2, 0)
		ButteredSausageAnimatorConfig.RotationPivot.TOP_RIGHT:
			return Vector2(node.size.x, 0)
		ButteredSausageAnimatorConfig.RotationPivot.CENTER_LEFT:
			return Vector2(0, node.size.y / 2)
		ButteredSausageAnimatorConfig.RotationPivot.CENTER:
			return node.size / 2
		ButteredSausageAnimatorConfig.RotationPivot.CENTER_RIGHT:
			return Vector2(node.size.x, node.size.y / 2)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_LEFT:
			return Vector2(0, node.size.y)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_CENTER:
			return Vector2(node.size.x / 2, node.size.y)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_RIGHT:
			return node.size
		ButteredSausageAnimatorConfig.RotationPivot.CUSTOM:
			return animator_config.rotation_pivot_custom
	return Vector2.ZERO


## Calculates the pivot offset for scale based on the configured pivot preset.[br][br]
##
## @param node - The Control node to calculate pivot for[br]
## @return The pivot offset as a Vector2[br]
func _get_scale_pivot_offset(node: Control) -> Vector2:
	match animator_config.scale_pivot_preset:
		ButteredSausageAnimatorConfig.RotationPivot.TOP_LEFT:
			return Vector2.ZERO
		ButteredSausageAnimatorConfig.RotationPivot.TOP_CENTER:
			return Vector2(node.size.x / 2, 0)
		ButteredSausageAnimatorConfig.RotationPivot.TOP_RIGHT:
			return Vector2(node.size.x, 0)
		ButteredSausageAnimatorConfig.RotationPivot.CENTER_LEFT:
			return Vector2(0, node.size.y / 2)
		ButteredSausageAnimatorConfig.RotationPivot.CENTER:
			return node.size / 2
		ButteredSausageAnimatorConfig.RotationPivot.CENTER_RIGHT:
			return Vector2(node.size.x, node.size.y / 2)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_LEFT:
			return Vector2(0, node.size.y)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_CENTER:
			return Vector2(node.size.x / 2, node.size.y)
		ButteredSausageAnimatorConfig.RotationPivot.BOTTOM_RIGHT:
			return node.size
		ButteredSausageAnimatorConfig.RotationPivot.CUSTOM:
			return animator_config.scale_pivot_custom
	return Vector2.ZERO


## Returns true if any animations are configured.[br]
## Excludes shake animation which is handled separately.[br][br]
##
## @return True if any animation is enabled[br]
func _has_animations() -> bool:
	return (animator_config.animate_slide_out or
			animator_config.animate_scale or
			animator_config.animate_rotation or
			animator_config.animate_position or
			animator_config.animate_color or
			animator_config.animate_fade)


## Animates the Control nodes with all configured effects.[br]
## Starts monitoring panel size changes after animation completes.[br][br]
func play() -> void:
	if not wrapper or not panel:
		push_error("ButteredSausageAnimator: wrapper or panel is null")
		return
	if slide_tween:
		slide_tween.kill()
	if animator_config.animate_shake:
		await shake()
		return

	# If no animations are configured, just show the wrapper and return
	if not _has_animations():
		wrapper.show()
		await wrapper.get_tree().process_frame
		if not is_instance_valid(wrapper) or not is_instance_valid(panel):
			return  # Objects were freed during await
		if animator_config.axis == Axis.VERTICAL:
			wrapper.custom_minimum_size.y = panel.get_combined_minimum_size().y
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		else:
			wrapper.custom_minimum_size.x = animator_config.panel_width
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		is_open = true
		start_monitoring()
		return

	var property_name: String
	var target_size: float
	var anim_speed: float = animator_config.animation_speed

	# Setup size - either animate it or set immediately
	if animator_config.animate_slide_out:
		if animator_config.axis == Axis.VERTICAL:
			property_name = Y_PROPERTY
			# Always get size from panel (PanelContainer), not rotation container
			# Rotation container is just a passthrough wrapper with no inherent size
			target_size = panel.get_combined_minimum_size().y
			if animator_config.open_direction == OpenDirection.POSITIVE:
				wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			else:
				wrapper.size_flags_vertical = Control.SIZE_SHRINK_END
			wrapper.custom_minimum_size.y = 0
		else:
			property_name = X_PROPERTY
			target_size = animator_config.panel_width
			if animator_config.open_direction == OpenDirection.POSITIVE:
				wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			else:
				wrapper.size_flags_horizontal = Control.SIZE_SHRINK_END
			wrapper.custom_minimum_size.x = 0
	# Setup initial states for animations
	if animator_config.animate_scale:
		panel.scale = animator_config.scale_from
		# Pivot offset will be set to center after layout for in-place scaling
	if animator_config.animate_rotation:
		# Use rotation_container for isolation (except in orbit mode where we rotate panel content)
		var rotation_target = panel if animator_config.rotation_orbit else (rotation_container if rotation_container else wrapper)
		rotation_target.rotation = deg_to_rad(animator_config.rotation_from_degrees)
		# Pivot offset will be set after layout when size is known
	if animator_config.animate_position:
		# Get scene rotation_container to apply position to the right node
		var scene_rotation_container = wrapper.get("rotation_container") if wrapper.has_method("get") else null
		# Apply position to rotation_container if it exists, otherwise to panel
		if scene_rotation_container:
			scene_rotation_container.position = animator_config.position_offset
		else:
			panel.position = animator_config.position_offset
	if animator_config.animate_color:
		# Get the stylebox and set initial color
		var stylebox = panel.get_theme_stylebox("panel")
		if stylebox:
			stylebox.bg_color = animator_config.color_from
	elif animator_config.animate_fade:
		wrapper.modulate.a = animator_config.fade_from

	# Enable clipping for size or position animations (reveal/contain effect)
	# Don't clip if rotation is active (extends beyond bounds)
	wrapper.clip_contents = (animator_config.animate_slide_out or animator_config.animate_position) and not animator_config.animate_rotation

	wrapper.show()
	await wrapper.get_tree().process_frame
	if not is_instance_valid(wrapper) or not is_instance_valid(panel):
		return  # Objects were freed during await

	# Set pivot offset for in-place scaling (now that panel.size is known)
	# When rotation_container exists, scale and rotation use different nodes - no conflict
	if animator_config.animate_scale:
		panel.pivot_offset = _get_scale_pivot_offset(panel)

	# Set pivot offset for rotation (now that node size is known)
	if animator_config.animate_rotation:
		var rotation_target = panel if animator_config.rotation_orbit else (rotation_container if rotation_container else wrapper)
		rotation_target.pivot_offset = _get_pivot_offset(rotation_target)

	# Set or recalculate size after frame
	if animator_config.animate_slide_out:
		if animator_config.axis == Axis.VERTICAL:
			# Always use panel's size directly
			target_size = panel.get_combined_minimum_size().y
		else:
			target_size = animator_config.panel_width
	else:
		# Not animating size - set wrapper to final size now
		if animator_config.axis == Axis.VERTICAL:
			# Just use panel's natural size - position moves within wrapper, clipping handles visibility
			wrapper.custom_minimum_size.y = panel.get_combined_minimum_size().y
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		else:
			# Just use panel's natural width - position moves within wrapper, clipping handles visibility
			wrapper.custom_minimum_size.x = animator_config.panel_width
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END

	# Create tween - always use parallel mode so all animations play simultaneously
	slide_tween = wrapper.create_tween()
	slide_tween.set_parallel(true)
	slide_tween.set_ease(animator_config.ease_type_open)
	slide_tween.set_trans(animator_config.transition_type)

	# Animate size if enabled
	if animator_config.animate_slide_out:
		slide_tween.tween_property(wrapper, property_name, target_size, anim_speed).from(0)

	# Animate other effects
	if animator_config.animate_scale:
		slide_tween.tween_property(panel, SCALE_PROPERTY, animator_config.scale_to, anim_speed)
	if animator_config.animate_rotation:
		# Calculate absolute rotation values to ensure animation plays
		var from_radians = deg_to_rad(animator_config.rotation_from_degrees)
		var to_radians = deg_to_rad(animator_config.rotation_to_degrees)
		# For 360° rotations, use TAU (2*PI) to ensure full rotation is visible
		if animator_config.rotation_to_degrees == 360.0 and animator_config.rotation_from_degrees == 0.0:
			to_radians = TAU
		# Use rotation_container for isolation (except in orbit mode where we rotate panel content)
		var rotation_target = panel if animator_config.rotation_orbit else (rotation_container if rotation_container else wrapper)
		slide_tween.tween_property(rotation_target, ROTATION_PROPERTY, to_radians, anim_speed).from(from_radians)
	if animator_config.animate_position:
		# Get scene rotation_container to animate the right node
		var scene_rotation_container = wrapper.get("rotation_container") if wrapper.has_method("get") else null
		# Animate position on rotation_container if it exists, otherwise on panel
		var position_target = scene_rotation_container if scene_rotation_container else panel
		slide_tween.tween_property(position_target, POSITION_PROPERTY, Vector2.ZERO, anim_speed)
	if animator_config.animate_color:
		# Tween the stylebox bg_color directly instead of modulating
		var stylebox = panel.get_theme_stylebox("panel")
		if stylebox:
			slide_tween.tween_property(stylebox, "bg_color", animator_config.color_to, anim_speed)
	elif animator_config.animate_fade:
		slide_tween.tween_property(wrapper, MODULATE_A_PROPERTY, animator_config.fade_to, anim_speed * 0.75)
	await slide_tween.finished
	is_open = true
	start_monitoring()


## Reverses all configured animations to hide the Control nodes.[br]
## Stops monitoring and resets all animation states after completion.[br][br]
func reverse() -> void:
	if not wrapper or not panel:
		return
	stop_monitoring()
	is_open = false
	if slide_tween:
		slide_tween.kill()
	if not wrapper.visible:
		return

	# If no animations are configured, just hide immediately
	if not _has_animations():
		wrapper.hide()
		if animator_config.axis == Axis.VERTICAL:
			wrapper.custom_minimum_size.y = 0
		else:
			wrapper.custom_minimum_size.x = 0
		return

	var property_name: String
	var current_size: float
	var anim_speed: float = animator_config.animation_speed

	# Setup size animation if enabled
	if animator_config.animate_slide_out:
		if animator_config.axis == Axis.VERTICAL:
			property_name = Y_PROPERTY
			current_size = wrapper.custom_minimum_size.y if wrapper.custom_minimum_size.y > 0 else wrapper.size.y
			wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
		else:
			property_name = X_PROPERTY
			current_size = wrapper.custom_minimum_size.x if wrapper.custom_minimum_size.x > 0 else wrapper.size.x
			wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END

	# Create tween - always use parallel mode
	slide_tween = wrapper.create_tween()
	slide_tween.set_parallel(true)
	slide_tween.set_ease(animator_config.ease_type_close)
	slide_tween.set_trans(animator_config.transition_type)

	# Animate size if enabled
	if animator_config.animate_slide_out:
		slide_tween.tween_property(wrapper, property_name, 0, anim_speed).from(current_size)

	# Animate other effects (reversed)
	if animator_config.animate_scale:
		slide_tween.tween_property(panel, SCALE_PROPERTY, animator_config.scale_from, anim_speed)
	if animator_config.animate_rotation:
		# Calculate absolute rotation values for reverse animation
		var from_radians = deg_to_rad(animator_config.rotation_from_degrees)
		var to_radians = deg_to_rad(animator_config.rotation_to_degrees)
		# For 360° rotations, use TAU to match the forward animation
		if animator_config.rotation_to_degrees == 360.0 and animator_config.rotation_from_degrees == 0.0:
			to_radians = TAU
		# Use rotation_container for isolation (except in orbit mode where we rotate panel content)
		var rotation_target = panel if animator_config.rotation_orbit else (rotation_container if rotation_container else wrapper)
		slide_tween.tween_property(rotation_target, ROTATION_PROPERTY, from_radians, anim_speed).from(to_radians)
	if animator_config.animate_position:
		# Get scene rotation_container to animate the right node
		var scene_rotation_container = wrapper.get("rotation_container") if wrapper.has_method("get") else null
		# Animate position on rotation_container if it exists, otherwise on panel
		var position_target = scene_rotation_container if scene_rotation_container else panel
		slide_tween.tween_property(position_target, POSITION_PROPERTY, animator_config.position_offset, anim_speed)
	if animator_config.animate_color:
		# Tween the stylebox bg_color directly instead of modulating
		var stylebox = panel.get_theme_stylebox("panel")
		if stylebox:
			slide_tween.tween_property(stylebox, "bg_color", animator_config.color_from, anim_speed)
	elif animator_config.animate_fade:
		slide_tween.tween_property(wrapper, MODULATE_A_PROPERTY, animator_config.fade_from, anim_speed)
	await slide_tween.finished
	wrapper.hide()

	# Reset size if it was animated
	if animator_config.animate_slide_out:
		if animator_config.axis == Axis.VERTICAL:
			wrapper.custom_minimum_size.y = 0
		else:
			wrapper.custom_minimum_size.x = 0

	# Reset other animation states
	if animator_config.animate_scale:
		panel.scale = Vector2.ONE
	if animator_config.animate_rotation:
		if animator_config.rotation_orbit:
			panel.rotation = 0.0
		elif rotation_container:
			rotation_container.rotation = 0.0
		else:
			wrapper.rotation = 0.0
	if animator_config.animate_position:
		# Get scene rotation_container to reset the right node
		var scene_rotation_container = wrapper.get("rotation_container") if wrapper.has_method("get") else null
		if scene_rotation_container:
			scene_rotation_container.position = Vector2.ZERO
		else:
			panel.position = Vector2.ZERO
	if animator_config.animate_color:
		# Reset stylebox color after animation
		var stylebox = panel.get_theme_stylebox("panel")
		if stylebox:
			stylebox.bg_color = animator_config.color_to
	elif animator_config.animate_fade:
		wrapper.modulate.a = 1.0

	# Disable clipping after animation completes
	wrapper.clip_contents = false


## Immediately hides the Control nodes without animation.[br]
## Stops monitoring and resets all animation states.[br][br]
func close_immediate() -> void:
	stop_monitoring()
	is_open = false
	if slide_tween:
		slide_tween.kill()
	if wrapper:
		wrapper.hide()

		# Reset size if it was animated
		if animator_config.animate_slide_out:
			if animator_config.axis == Axis.VERTICAL:
				wrapper.custom_minimum_size.y = 0
				wrapper.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END
			else:
				wrapper.custom_minimum_size.x = 0
				wrapper.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if animator_config.open_direction == OpenDirection.POSITIVE else Control.SIZE_SHRINK_END

		# Reset other animation states
		if animator_config.animate_scale:
			panel.scale = Vector2.ONE
		if animator_config.animate_rotation:
			if animator_config.rotation_orbit:
				panel.rotation = 0.0
			elif rotation_container:
				rotation_container.rotation = 0.0
			else:
				wrapper.rotation = 0.0
		if animator_config.animate_position:
			# Get scene rotation_container to reset the right node
			var scene_rotation_container = wrapper.get("rotation_container") if wrapper.has_method("get") else null
			if scene_rotation_container:
				scene_rotation_container.position = Vector2.ZERO
			else:
				panel.position = Vector2.ZERO
		if animator_config.animate_color:
			# Reset stylebox color
			var stylebox = panel.get_theme_stylebox("panel")
			if stylebox:
				stylebox.bg_color = animator_config.color_to
		elif animator_config.animate_fade:
			wrapper.modulate.a = 1.0

		# Disable clipping
		wrapper.clip_contents = false


## Shakes the wrapper Control horizontally with decreasing intensity.[br]
## Useful for error emphasis or attention-grabbing effects.[br][br]
func shake() -> void:
	if not wrapper or not wrapper.visible:
		return
	var shake_tween = wrapper.create_tween()
	var shake_amount: float = animator_config.shake_amount
	var shake_speed: float = animator_config.shake_speed
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, shake_amount, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, -shake_amount, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, shake_amount / 2.0, shake_speed)
	shake_tween.tween_property(wrapper, POSITION_X_PROPERTY, 0, shake_speed)
	await shake_tween.finished


## Starts monitoring panel size changes to automatically update wrapper size.[br][br]
func start_monitoring() -> void:
	if _monitoring or not panel:
		return
	if not panel.minimum_size_changed.is_connected(_on_panel_size_changed):
		panel.minimum_size_changed.connect(_on_panel_size_changed)
		_monitoring = true


## Stops monitoring panel size changes and disconnects the signal.[br][br]
func stop_monitoring() -> void:
	if not _monitoring or not panel:
		return
	if panel.minimum_size_changed.is_connected(_on_panel_size_changed):
		panel.minimum_size_changed.disconnect(_on_panel_size_changed)
	_monitoring = false


## Called when panel minimum size changes to update wrapper size.[br][br]
func _on_panel_size_changed() -> void:
	if not is_open or not wrapper or not wrapper.visible or not panel:
		return
	# Always use panel's size directly - rotation container is just a passthrough
	if animator_config.axis == Axis.VERTICAL:
		var new_height = panel.get_combined_minimum_size().y
		if abs(wrapper.custom_minimum_size.y - new_height) > 1.0:
			wrapper.custom_minimum_size.y = new_height
	else:
		var new_width = panel.get_combined_minimum_size().x
		if abs(wrapper.custom_minimum_size.x - new_width) > 1.0:
			wrapper.custom_minimum_size.x = new_width
		


## Initializes the animator with wrapper and panel Controls and configuration.[br][br]
##
## @param panel_wrapper - The wrapper Control that contains the panel[br]
## @param panel_container - The panel Control to animate[br]
## @param config - The animator configuration resource[br]
func _init(panel_wrapper: Control, panel_container: Control, config: ButteredSausageAnimatorConfig) -> void:
	wrapper = panel_wrapper
	panel = panel_container
	animator_config = config

	# Always use rotation container when rotating (unless in orbit mode)
	# This isolates rotation from wrapper's layout responsibilities
	if animator_config.animate_rotation and not animator_config.rotation_orbit:
		if wrapper.has_method("get") and wrapper.get("rotation_container"):
			rotation_container = wrapper.get("rotation_container")
