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
const TEXT_EFFECTS_SHADER_FILE: String = "shaders/text_effects.gdshader"

var wrapper: Control
var panel: Control
var rotation_container: Control  # Middle layer for rotation isolation
var slide_tween: Tween
var text_tween: Tween  # Tween for text animations (typewriter/apparate)
var wave_fade_tween: Tween  # Tween for wave duration fade-out
var shake_fade_tween: Tween  # Tween for shake duration fade-out
var glitch_fade_tween: Tween  # Tween for glitch duration fade-out
var text_label: RichTextLabel  # Optional label for text effects
var text_shader_material: ShaderMaterial  # Shader material for text effects
var _original_label_material: Material  # Store original material to restore later
var is_open: bool = false
var _monitoring: bool = false
var animator_config: ButteredSausageAnimatorConfig
var _target_visible_chars: int = 0  # Target character count for skip functionality


## Configures the animator with animation parameters.[br][br]
##
## @param config - The animator configuration resource[br]
## @return This animator instance for method chaining[br]
func configure(config: ButteredSausageAnimatorConfig) -> ButteredSausageAnimator:
	animator_config = config
	return self


## Sets the text label for text effects (typewriter, apparate, wave, etc.).[br][br]
##
## @param label - The RichTextLabel to animate[br]
## @return This animator instance for method chaining[br]
func set_text_label(label: RichTextLabel) -> ButteredSausageAnimator:
	text_label = label
	return self


## Returns true if any text animations are configured.[br][br]
##
## @return True if any text effect is enabled[br]
func _has_text_animations() -> bool:
	return (animator_config.animate_typewriter or
			animator_config.animate_text_apparate or
			animator_config.animate_text_crawl or
			_has_continuous_text_effects())


## Returns true if any continuous shader effects are configured.[br][br]
##
## @return True if wave, shake, glitch, rainbow, or pulse is enabled[br]
func _has_continuous_text_effects() -> bool:
	return (animator_config.animate_text_wave or
			animator_config.animate_text_shake or
			animator_config.animate_text_glitch or
			animator_config.animate_text_rainbow or
			animator_config.animate_text_pulse)


## Plays text animations on the text label.[br]
## Called automatically by play() if text_label is set and text animations are enabled.[br][br]
func _play_text_animations() -> void:
	if not text_label or not _has_text_animations():
		return

	var text_content = text_label.get_parsed_text()
	var char_count = text_content.length()
	if char_count == 0:
		return

	_target_visible_chars = char_count

	# Apply shader if any shader-based effects are enabled
	var needs_shader = (animator_config.animate_text_apparate or
			animator_config.animate_text_crawl or
			_has_continuous_text_effects())
	if needs_shader:
		_apply_text_shader()
		_setup_continuous_effects()

	# Set up tween for one-time animations
	if text_tween:
		text_tween.kill()

	if animator_config.animate_typewriter:
		# Typewriter: reveal characters at a constant rate
		text_label.visible_characters = 0
		text_tween = text_label.create_tween()
		var duration = char_count / animator_config.characters_per_second
		text_tween.tween_property(text_label, "visible_characters", char_count, duration)

	elif animator_config.animate_text_apparate:
		# Apparate: shader-based mystical scattered fade effect
		text_shader_material.set_shader_parameter("apparate_enabled", 1.0)
		text_shader_material.set_shader_parameter("apparate_progress", 0.0)
		text_shader_material.set_shader_parameter("apparate_spread", animator_config.apparate_spread)

		# Show all characters immediately - shader handles the fade
		text_label.visible_characters = char_count

		# Tween progress to 1.0 + spread so fade band clears the right edge completely
		text_tween = text_label.create_tween()
		var end_progress = 1.0 + animator_config.apparate_spread
		text_tween.tween_property(text_shader_material, "shader_parameter/apparate_progress", end_progress, animator_config.apparate_duration)

	elif animator_config.animate_text_crawl:
		# Crawl: Star Wars style scrolling text
		_setup_crawl_effect()

	else:
		# No one-time animation, just show all characters for continuous effects
		text_label.visible_characters = char_count


## Sets up the crawl effect (Star Wars style scrolling text).[br]
## Uses position-based scrolling with clipping instead of shader UV manipulation.[br][br]
func _setup_crawl_effect() -> void:
	if not text_label:
		push_error("ButteredSausageAnimator: crawl effect - missing text_label")
		return

	# Show all characters immediately
	text_label.visible_characters = _target_visible_chars

	# Get content height (full text height)
	var content_height = text_label.get_content_height()
	if content_height <= 0:
		content_height = text_label.size.y
	if content_height <= 0:
		content_height = 100.0
		push_warning("ButteredSausageAnimator: crawl effect - using fallback content height")

	var viewport_height = animator_config.crawl_height
	var original_parent = text_label.get_parent()

	# Create a clipping viewport container
	var crawl_viewport = Control.new()
	crawl_viewport.name = "CrawlViewport"
	crawl_viewport.clip_contents = true
	crawl_viewport.custom_minimum_size.y = viewport_height
	crawl_viewport.custom_minimum_size.x = 0
	crawl_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crawl_viewport.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	# Force size to not exceed minimum (prevent expansion)
	crawl_viewport.set_deferred("size", Vector2(0, viewport_height))

	# Get label's position in parent before reparenting
	var label_index = text_label.get_index()
	var label_size_flags_h = text_label.size_flags_horizontal

	# Insert viewport container where label was
	original_parent.add_child(crawl_viewport)
	original_parent.move_child(crawl_viewport, label_index)

	# Reparent label into viewport container
	text_label.reparent(crawl_viewport)

	# Keep label's horizontal size flags for proper width in HBox
	crawl_viewport.size_flags_horizontal = label_size_flags_h

	# Disable fit_content so the label doesn't try to size itself
	if text_label.has_method("set_fit_content"):
		text_label.set_fit_content(false)
	elif "fit_content" in text_label:
		text_label.fit_content = false

	# Configure label for absolute positioning within viewport
	text_label.anchor_top = 0.0
	text_label.anchor_bottom = 0.0
	text_label.anchor_left = 0.0
	text_label.anchor_right = 1.0
	text_label.offset_top = 0.0
	text_label.offset_bottom = content_height
	text_label.offset_left = 0.0
	text_label.offset_right = 0.0

	# Make sure label doesn't expand the viewport
	text_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	# Start with text at bottom of viewport (Star Wars style - text enters from below)
	text_label.position.y = viewport_height

	# Update wrapper size to match the new panel size with crawl viewport
	if wrapper and panel:
		wrapper.custom_minimum_size.y = panel.get_combined_minimum_size().y

	# Calculate scroll distance: from bottom of viewport to all text exited top
	var scroll_distance = viewport_height + content_height

	# Calculate duration based on speed (pixels per second)
	var duration = scroll_distance / animator_config.crawl_speed
	duration = max(duration, 1.0)

	# Set up shader for fade effect at top of viewport
	var fade_pixels = viewport_height * animator_config.crawl_fade_height
	if text_shader_material and fade_pixels > 0.0:
		text_shader_material.set_shader_parameter("crawl_enabled", 1.0)
		text_shader_material.set_shader_parameter("crawl_fade_pixels", fade_pixels)
		text_shader_material.set_shader_parameter("crawl_label_position_y", viewport_height)

	# Animate label position scrolling up
	text_tween = text_label.create_tween()
	text_tween.set_parallel(true)

	# Tween the label's position
	text_tween.tween_property(
		text_label,
		"position:y",
		-content_height,
		duration
	)

	# Tween the shader parameter in sync (for fade effect)
	if text_shader_material and fade_pixels > 0.0:
		text_tween.tween_property(
			text_shader_material,
			"shader_parameter/crawl_label_position_y",
			-content_height,
			duration
		)


## Sets up continuous shader effects (wave, shake, rainbow, pulse).[br]
## These effects run continuously using TIME and don't need tweening.[br][br]
func _setup_continuous_effects() -> void:
	if not text_shader_material:
		return

	# Kill any existing fade tweens
	if wave_fade_tween:
		wave_fade_tween.kill()
	if shake_fade_tween:
		shake_fade_tween.kill()
	if glitch_fade_tween:
		glitch_fade_tween.kill()

	# Wave effect
	if animator_config.animate_text_wave:
		text_shader_material.set_shader_parameter("wave_enabled", 1.0)
		text_shader_material.set_shader_parameter("wave_horizontal", 1.0 if animator_config.wave_horizontal else 0.0)
		text_shader_material.set_shader_parameter("wave_amplitude", animator_config.wave_amplitude)
		text_shader_material.set_shader_parameter("wave_frequency", animator_config.wave_frequency)
		text_shader_material.set_shader_parameter("wave_speed", animator_config.wave_speed)

		# Fade out wave after duration (if > 0)
		if animator_config.wave_duration > 0.0 and text_label:
			wave_fade_tween = text_label.create_tween()
			wave_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/wave_amplitude",
				0.0,
				animator_config.wave_duration
			)
	else:
		text_shader_material.set_shader_parameter("wave_enabled", 0.0)

	# Shake effect
	if animator_config.animate_text_shake:
		text_shader_material.set_shader_parameter("shake_enabled", 1.0)
		text_shader_material.set_shader_parameter("shake_amount", animator_config.text_shake_amount)
		text_shader_material.set_shader_parameter("shake_speed", animator_config.text_shake_speed)

		# Fade out shake after duration (if > 0)
		if animator_config.text_shake_duration > 0.0 and text_label:
			shake_fade_tween = text_label.create_tween()
			shake_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/shake_amount",
				0.0,
				animator_config.text_shake_duration
			)
	else:
		text_shader_material.set_shader_parameter("shake_enabled", 0.0)

	# Glitch effect
	if animator_config.animate_text_glitch:
		text_shader_material.set_shader_parameter("glitch_enabled", 1.0)
		text_shader_material.set_shader_parameter("glitch_intensity", animator_config.glitch_intensity)
		text_shader_material.set_shader_parameter("glitch_speed", animator_config.glitch_speed)
		text_shader_material.set_shader_parameter("glitch_block_size", animator_config.glitch_block_size)
		text_shader_material.set_shader_parameter("glitch_color_drift", animator_config.glitch_color_drift)

		# Fade out glitch after duration (if > 0)
		if animator_config.glitch_duration > 0.0 and text_label:
			glitch_fade_tween = text_label.create_tween()
			glitch_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/glitch_intensity",
				0.0,
				animator_config.glitch_duration
			)
	else:
		text_shader_material.set_shader_parameter("glitch_enabled", 0.0)

	# Rainbow effect
	if animator_config.animate_text_rainbow:
		text_shader_material.set_shader_parameter("rainbow_enabled", 1.0)
		text_shader_material.set_shader_parameter("rainbow_frequency", animator_config.rainbow_frequency)
		text_shader_material.set_shader_parameter("rainbow_speed", animator_config.rainbow_speed)
		text_shader_material.set_shader_parameter("rainbow_saturation", animator_config.rainbow_saturation)
	else:
		text_shader_material.set_shader_parameter("rainbow_enabled", 0.0)

	# Pulse effect
	if animator_config.animate_text_pulse:
		text_shader_material.set_shader_parameter("pulse_enabled", 1.0)
		text_shader_material.set_shader_parameter("pulse_speed", animator_config.pulse_speed)
		text_shader_material.set_shader_parameter("pulse_min_alpha", animator_config.pulse_min_alpha)
	else:
		text_shader_material.set_shader_parameter("pulse_enabled", 0.0)


## Gets the character positions where each word ends (including trailing space).[br][br]
##
## @param text - The text to analyze[br]
## @return Array of character indices marking word boundaries[br]
func _get_word_end_positions(text: String) -> Array[int]:
	var positions: Array[int] = []
	var in_word = false

	for i in range(text.length()):
		var char = text[i]
		var is_whitespace = char == " " or char == "\t" or char == "\n"

		if in_word and is_whitespace:
			# End of word - include the whitespace
			positions.append(i + 1)
			in_word = false
		elif not is_whitespace:
			in_word = true

	# Add final position if text doesn't end with whitespace
	if in_word:
		positions.append(text.length())

	return positions


## Applies the text effects shader to the text label.[br]
## Creates and caches the ShaderMaterial for reuse.[br][br]
func _apply_text_shader() -> void:
	if not text_label:
		return

	# Store original material to restore later if needed
	if not _original_label_material and text_label.material:
		_original_label_material = text_label.material

	# Create shader material if not already created
	if not text_shader_material:
		# Build path relative to this script's location (works regardless of addon folder name)
		var script_path = get_script().resource_path.get_base_dir()  # res://addons/[addon]/ui
		var addon_path = script_path.get_base_dir()  # res://addons/[addon]
		var shader_path = addon_path.path_join(TEXT_EFFECTS_SHADER_FILE)
		var shader = load(shader_path)
		if not shader:
			push_error("ButteredSausageAnimator: Failed to load shader from " + shader_path)
			return
		text_shader_material = ShaderMaterial.new()
		text_shader_material.shader = shader

	# Reset all effects to disabled (they'll be enabled as needed)
	text_shader_material.set_shader_parameter("wave_enabled", 0.0)
	text_shader_material.set_shader_parameter("shake_enabled", 0.0)
	text_shader_material.set_shader_parameter("glitch_enabled", 0.0)
	text_shader_material.set_shader_parameter("rainbow_enabled", 0.0)
	text_shader_material.set_shader_parameter("apparate_enabled", 0.0)
	text_shader_material.set_shader_parameter("pulse_enabled", 0.0)
	text_shader_material.set_shader_parameter("crawl_enabled", 0.0)

	text_label.material = text_shader_material


## Removes the text effects shader and restores the original material.[br][br]
func _remove_text_shader() -> void:
	if text_label:
		text_label.material = _original_label_material
	text_shader_material = null


## Skips the current text animation, completing it instantly.[br]
## Called when skip_on_click is enabled and user clicks the panel.[br][br]
func skip_text_animation() -> void:
	if text_tween and text_tween.is_running():
		text_tween.kill()
	if text_label and _target_visible_chars > 0:
		text_label.visible_characters = _target_visible_chars
		text_label.modulate.a = 1.0

		# Complete apparate animation if active (use 2.0 to ensure fade band is fully past)
		if text_shader_material and animator_config.animate_text_apparate:
			text_shader_material.set_shader_parameter("apparate_progress", 2.0)


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

	# If no panel animations are configured, just show the wrapper
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
		# Text animations can still run even without panel animations
		_play_text_animations()
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

	# Start text animations (runs independently of panel animations)
	_play_text_animations()

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
