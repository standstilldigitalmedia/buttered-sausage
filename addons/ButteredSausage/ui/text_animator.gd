## Animates RichTextLabel nodes with typewriter, apparate, wave, shake, glitch, rainbow, pulse, and crawl effects.[br]
## Can be used standalone for dialogue systems, RPG text, or any text animation needs.[br][br]
##
## Dependencies: ButteredSausageTextAnimatorConfig only.[br]
## Created by passing a RichTextLabel to the constructor, then configure() and play().
class_name ButteredSausageTextAnimator
extends RefCounted

signal finished  ## Emitted when play() or reverse() completes. Use to await parallel animations.

const TEXT_EFFECTS_SHADER_FILE: String = "shaders/text_effects.gdshader"

var text_label: RichTextLabel
var config: ButteredSausageTextAnimatorConfig
var text_tween: Tween
var wave_fade_tween: Tween
var shake_fade_tween: Tween
var glitch_fade_tween: Tween
var text_shader_material: ShaderMaterial
var _original_label_material: Material
var _target_visible_chars: int = 0
var _crawl_viewport: Control  # Reference to created crawl viewport


## Configures the text animator with animation parameters.[br][br]
##
## @param cfg - The text animator configuration resource[br]
## @return This animator instance for method chaining[br]
func configure(cfg: ButteredSausageTextAnimatorConfig) -> ButteredSausageTextAnimator:
	config = cfg
	return self


## Returns true if any text animations are configured.[br][br]
##
## @return True if any text effect is enabled[br]
func _has_text_animations() -> bool:
	return (config.animate_typewriter or
			config.animate_text_apparate or
			config.animate_text_crawl or
			_has_continuous_text_effects())


## Returns true if any continuous shader effects are configured.[br][br]
##
## @return True if wave, shake, glitch, rainbow, or pulse is enabled[br]
func _has_continuous_text_effects() -> bool:
	return (config.animate_text_wave or
			config.animate_text_shake or
			config.animate_text_glitch or
			config.animate_text_rainbow or
			config.animate_text_pulse)


## Plays the configured text animations.[br][br]
##
## @param duration - Duration for continuous effects (0 = infinite for continuous, natural duration for entrance effects)[br]
func play(duration: float = 0.0) -> void:
	if not text_label or not config or not _has_text_animations():
		finished.emit()
		return

	var text_content = text_label.get_parsed_text()
	var char_count = text_content.length()
	if char_count == 0:
		finished.emit()
		return

	_target_visible_chars = char_count

	# Apply shader if any shader-based effects are enabled
	var needs_shader = (config.animate_text_apparate or
			config.animate_text_crawl or
			_has_continuous_text_effects())
	if needs_shader:
		_apply_text_shader()
		_setup_continuous_effects(duration)

	# Set up tween for one-time animations
	if text_tween:
		text_tween.kill()

	if config.animate_typewriter:
		# Typewriter: reveal characters at a constant rate
		text_label.visible_characters = 0
		text_tween = text_label.create_tween()
		var type_duration = char_count / config.characters_per_second
		text_tween.tween_property(text_label, "visible_characters", char_count, type_duration)
		await text_tween.finished

	elif config.animate_text_apparate:
		# Apparate: shader-based mystical scattered fade effect
		text_shader_material.set_shader_parameter("apparate_enabled", 1.0)
		text_shader_material.set_shader_parameter("apparate_progress", 0.0)
		text_shader_material.set_shader_parameter("apparate_spread", config.apparate_spread)

		# Show all characters immediately - shader handles the fade
		text_label.visible_characters = char_count

		# Tween progress to 1.0 + spread so fade band clears the right edge completely
		text_tween = text_label.create_tween()
		var end_progress = 1.0 + config.apparate_spread
		var apparate_duration = end_progress / config.apparate_speed
		text_tween.tween_property(text_shader_material, "shader_parameter/apparate_progress", end_progress, apparate_duration)
		await text_tween.finished

	elif config.animate_text_crawl:
		# Crawl: Star Wars style scrolling text
		await _setup_crawl_effect()

	else:
		# No one-time animation, just show all characters for continuous effects
		text_label.visible_characters = char_count
		# For continuous-only effects with duration, wait for the duration
		if duration > 0.0 and _has_continuous_text_effects():
			await text_label.get_tree().create_timer(duration).timeout

	finished.emit()


## Reverses the text animation (for typewriter/apparate).[br]
## For continuous effects, this stops them.[br][br]
func reverse() -> void:
	if not text_label or not config:
		finished.emit()
		return

	# Kill existing tweens
	if text_tween:
		text_tween.kill()
	if wave_fade_tween:
		wave_fade_tween.kill()
	if shake_fade_tween:
		shake_fade_tween.kill()
	if glitch_fade_tween:
		glitch_fade_tween.kill()

	if config.animate_typewriter:
		# Reverse typewriter: hide characters one by one
		var current_chars = text_label.visible_characters
		if current_chars < 0:
			current_chars = _target_visible_chars
		text_tween = text_label.create_tween()
		var type_duration = current_chars / config.characters_per_second
		text_tween.tween_property(text_label, "visible_characters", 0, type_duration)
		await text_tween.finished

	elif config.animate_text_apparate and text_shader_material:
		# Reverse apparate: fade back out
		var current_progress = text_shader_material.get_shader_parameter("apparate_progress")
		if current_progress == null:
			current_progress = 1.0 + config.apparate_spread
		var apparate_duration = current_progress / config.apparate_speed
		text_tween = text_label.create_tween()
		text_tween.tween_property(text_shader_material, "shader_parameter/apparate_progress", 0.0, apparate_duration)
		await text_tween.finished

	elif config.animate_text_crawl:
		# For crawl, just stop the animation
		pass

	# Disable continuous effects
	if text_shader_material:
		text_shader_material.set_shader_parameter("wave_enabled", 0.0)
		text_shader_material.set_shader_parameter("shake_enabled", 0.0)
		text_shader_material.set_shader_parameter("glitch_enabled", 0.0)
		text_shader_material.set_shader_parameter("rainbow_enabled", 0.0)
		text_shader_material.set_shader_parameter("pulse_enabled", 0.0)

	finished.emit()


## Skips the current text animation, completing it instantly.[br]
## Called when skip_on_click is enabled and user clicks.[br][br]
func skip() -> void:
	if text_tween and text_tween.is_running():
		text_tween.kill()
	if text_label and _target_visible_chars > 0:
		text_label.visible_characters = _target_visible_chars
		text_label.modulate.a = 1.0

		# Complete apparate animation if active (use 2.0 to ensure fade band is fully past)
		if text_shader_material and config.animate_text_apparate:
			text_shader_material.set_shader_parameter("apparate_progress", 2.0)


## Sets up the crawl effect (Star Wars style scrolling text).[br]
## Creates a clipping viewport and reparents the label into it.[br][br]
func _setup_crawl_effect() -> void:
	if not text_label:
		push_error("ButteredSausageTextAnimator: crawl effect - missing text_label")
		return

	# Show all characters immediately
	text_label.visible_characters = _target_visible_chars

	# Get content height (full text height)
	var content_height = text_label.get_content_height()
	if content_height <= 0:
		content_height = text_label.size.y
	if content_height <= 0:
		content_height = 100.0
		push_warning("ButteredSausageTextAnimator: crawl effect - using fallback content height")

	var viewport_height = config.crawl_height
	var original_parent = text_label.get_parent()

	# Create a clipping viewport container
	_crawl_viewport = Control.new()
	_crawl_viewport.name = "CrawlViewport"
	_crawl_viewport.clip_contents = true
	_crawl_viewport.custom_minimum_size.y = viewport_height
	_crawl_viewport.custom_minimum_size.x = 0
	_crawl_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# 0 = shrink to beginning (default when SIZE_SHRINK_CENTER and SIZE_SHRINK_END not set)
	_crawl_viewport.size_flags_vertical = 0
	# Force size to not exceed minimum (prevent expansion)
	_crawl_viewport.set_deferred("size", Vector2(0, viewport_height))

	# Get label's position in parent before reparenting
	var label_index = text_label.get_index()
	var label_size_flags_h = text_label.size_flags_horizontal

	# Insert viewport container where label was
	original_parent.add_child(_crawl_viewport)
	original_parent.move_child(_crawl_viewport, label_index)

	# Reparent label into viewport container
	text_label.reparent(_crawl_viewport)

	# Keep label's horizontal size flags for proper width in HBox
	_crawl_viewport.size_flags_horizontal = label_size_flags_h

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
	# 0 = shrink to beginning (default when SIZE_SHRINK_CENTER and SIZE_SHRINK_END not set)
	text_label.size_flags_vertical = 0

	# Start with text at bottom of viewport (Star Wars style - text enters from below)
	text_label.position.y = viewport_height

	# Calculate scroll distance: from bottom of viewport to all text exited top
	var scroll_distance = viewport_height + content_height

	# Calculate duration based on speed (pixels per second)
	var duration = scroll_distance / config.crawl_speed
	duration = max(duration, 1.0)

	# Set up shader for fade effect at top of viewport
	var fade_pixels = viewport_height * config.crawl_fade_height
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

	await text_tween.finished


## Sets up continuous shader effects (wave, shake, glitch, rainbow, pulse).[br]
## These effects run continuously using TIME and don't need tweening.[br][br]
##
## @param duration - Duration before effects fade out (0 = infinite)[br]
func _setup_continuous_effects(duration: float) -> void:
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
	if config.animate_text_wave:
		text_shader_material.set_shader_parameter("wave_enabled", 1.0)
		text_shader_material.set_shader_parameter("wave_horizontal", 1.0 if config.wave_horizontal else 0.0)
		text_shader_material.set_shader_parameter("wave_amplitude", config.wave_amplitude)
		text_shader_material.set_shader_parameter("wave_frequency", config.wave_frequency)
		text_shader_material.set_shader_parameter("wave_speed", config.wave_speed)

		# Fade out wave after duration (if > 0)
		if duration > 0.0 and text_label:
			wave_fade_tween = text_label.create_tween()
			wave_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/wave_amplitude",
				0.0,
				duration
			)
	else:
		text_shader_material.set_shader_parameter("wave_enabled", 0.0)

	# Shake effect
	if config.animate_text_shake:
		text_shader_material.set_shader_parameter("shake_enabled", 1.0)
		text_shader_material.set_shader_parameter("shake_amount", config.text_shake_amount)
		text_shader_material.set_shader_parameter("shake_speed", config.text_shake_speed)

		# Fade out shake after duration (if > 0)
		if duration > 0.0 and text_label:
			shake_fade_tween = text_label.create_tween()
			shake_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/shake_amount",
				0.0,
				duration
			)
	else:
		text_shader_material.set_shader_parameter("shake_enabled", 0.0)

	# Glitch effect
	if config.animate_text_glitch:
		text_shader_material.set_shader_parameter("glitch_enabled", 1.0)
		text_shader_material.set_shader_parameter("glitch_intensity", config.glitch_intensity)
		text_shader_material.set_shader_parameter("glitch_speed", config.glitch_speed)
		text_shader_material.set_shader_parameter("glitch_block_size", config.glitch_block_size)
		text_shader_material.set_shader_parameter("glitch_color_drift", config.glitch_color_drift)

		# Fade out glitch after duration (if > 0)
		if duration > 0.0 and text_label:
			glitch_fade_tween = text_label.create_tween()
			glitch_fade_tween.tween_property(
				text_shader_material,
				"shader_parameter/glitch_intensity",
				0.0,
				duration
			)
	else:
		text_shader_material.set_shader_parameter("glitch_enabled", 0.0)

	# Rainbow effect
	if config.animate_text_rainbow:
		text_shader_material.set_shader_parameter("rainbow_enabled", 1.0)
		text_shader_material.set_shader_parameter("rainbow_frequency", config.rainbow_frequency)
		text_shader_material.set_shader_parameter("rainbow_speed", config.rainbow_speed)
		text_shader_material.set_shader_parameter("rainbow_saturation", config.rainbow_saturation)
	else:
		text_shader_material.set_shader_parameter("rainbow_enabled", 0.0)

	# Pulse effect
	if config.animate_text_pulse:
		text_shader_material.set_shader_parameter("pulse_enabled", 1.0)
		text_shader_material.set_shader_parameter("pulse_speed", config.pulse_speed)
		text_shader_material.set_shader_parameter("pulse_min_alpha", config.pulse_min_alpha)
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
			push_error("ButteredSausageTextAnimator: Failed to load shader from " + shader_path)
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


## Returns reference to the crawl viewport if one was created.[br]
## Useful for callers who need to adjust layout after crawl animation.[br][br]
##
## @return The CrawlViewport Control or null if crawl was not used[br]
func get_crawl_viewport() -> Control:
	return _crawl_viewport


## Initializes the text animator with a RichTextLabel.[br][br]
##
## @param label - The RichTextLabel to animate[br]
func _init(label: RichTextLabel) -> void:
	text_label = label
