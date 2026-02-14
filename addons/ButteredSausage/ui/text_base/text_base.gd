@tool
class_name ButteredSausageTextBase
extends RichTextLabel

enum Alignment {
	Left,     ## Align message text to the left edge of the panel
	Center,   ## Center message text within the panel (default, most common)
	Right,    ## Align message text to the right edge of the panel
	Justify   ## Stretch text to fill the width of the panel
}

@export_group("Text Alignment")
@export var label_text_alignment: Alignment = Alignment.Center  ## Horizontal alignment for message text within the panel (Left, Center, Right, or Justify).

@export_group("Font")
@export var font: Font  ## Custom font resource for message text. Leave empty to use default theme font.
@export var font_color: Color = Color(1.0, 1.0, 1.0, 1.0)  ## Color of the message text. Remains constant during color animations.
@export var font_size: int = 12  ## Size of the message text in pixels.

@export_group("Animation Chains")
@export var entrance_animation_chain: Array[ButteredSausageTextStep] = []  ## Sequence of animation steps played when panel opens. Each step wraps an AnimatorConfig with optional reverse, loop, and delay. Leave empty for instant appearance.
@export var exit_animation_chain: Array[ButteredSausageTextStep] = []  ## Custom animation steps for closing. If empty, uses close_behavior instead.
@export var close_behavior: ButteredSausagePanelBase.CloseBehavior = ButteredSausagePanelBase.CloseBehavior.REVERSE_FIRST_ANIMATION  ## How to animate closing when exit_animation_chain is empty. Can reverse first animation, mirror full chain, or skip animation.

var is_stopping: bool = false
var text_animator: ButteredSausageTextAnimator  # Cached animator for text effects and skip_on_click


func configure() -> void:
	if font:
		add_theme_font_override("normal_font", font)
	add_theme_color_override("default_color", font_color)
	add_theme_font_size_override("normal_font_size", font_size)
	horizontal_alignment = label_text_alignment as int
	
	
func start() -> void:
	# If no animations configured, just show panel without animation
	if entrance_animation_chain.is_empty():
		show()
		return

	# Play entire animation chain once and detect if any want to loop
	var has_looping_animations: bool = false
	var is_first_step: bool = true
	for step in entrance_animation_chain:
		# Skip steps with no animations assigned
		if not step.text_animation:
			continue

		# Apply delay before this step
		if step.delay_before > 0.0:
			await get_tree().create_timer(step.delay_before).timeout
			if is_stopping:
				break

		var text_anim: ButteredSausageTextAnimator = null

		# Text animations only run on first step
		if step.text_animation and is_first_step:
			text_anim = ButteredSausageTextAnimator.new(self)
			text_anim.configure(step.text_animation)
			# Cache animator for skip_on_click
			if step.text_animation.animate_typewriter or step.text_animation.animate_text_apparate:
				text_animator = text_anim
			is_first_step = false

		if text_anim:
			if step.text_reverse:
				text_anim.reverse()
			else:
				text_anim.play(step.text_duration)

		# Wait for animations to complete
		# For text animations with duration=0 (infinite), don't wait - let them continue
		if text_anim and step.text_duration > 0:
			await text_anim.finished

		# Handle crawl layout adjustment
		if step.text_animation and step.text_animation.animate_text_crawl:
			custom_minimum_size.y = get_combined_minimum_size().y
			
			
func animate_out() -> void:
	# Priority 1: Use custom exit animation chain if provided
	if !exit_animation_chain.is_empty():
		for step in exit_animation_chain:
			if !step.text_animation:
				continue

			# Apply delay before this step
			if step.delay_before > 0.0:
				await get_tree().create_timer(step.delay_before).timeout
			
			var text_anim = ButteredSausageTextAnimator.new(self)
			text_anim.configure(step.text_animation)
			if step.text_reverse:
				text_anim.play(step.text_duration)
			else:
				text_anim.reverse()
			if step.text_duration > 0:
				await text_anim.finished
		hide()
		return

	# Priority 2: Use close_behavior setting
	match close_behavior:
		ButteredSausagePanelBase.CloseBehavior.NO_ANIMATION:
			# Just hide immediately
			hide()

		ButteredSausagePanelBase.CloseBehavior.MIRROR_FULL_CHAIN:
			# Reverse entire animation chain in reverse order
			if entrance_animation_chain.is_empty():
				hide()
			else:
				for i in range(entrance_animation_chain.size() - 1, -1, -1):
					var step = entrance_animation_chain[i]

					# Skip steps with no panel animation assigned
					if not step.text_animation:
						continue

					# Apply delay before this step
					if step.delay_before > 0.0:
						await get_tree().create_timer(step.delay_before).timeout

					var text_anim = ButteredSausageTextAnimator.new(self)
					text_anim.configure(step.text_animation)
					if step.text_reverse:
						text_anim.play(step.text_duration)
					else:
						text_anim.reverse()
					if step.text_duration > 0:
						await text_anim.finished
				hide()

		ButteredSausagePanelBase.CloseBehavior.REVERSE_FIRST_ANIMATION:
			# Default - reverse just the first animation
			if entrance_animation_chain.is_empty():
				hide()
			else:
				var step = entrance_animation_chain[0]

				# Only reverse if text animation is assigned
				if step.text_animation:
					# Apply delay before this step
					if step.delay_before > 0.0:
						await get_tree().create_timer(step.delay_before).timeout

					var text_anim = ButteredSausageTextAnimator.new(self)
					text_anim.configure(step.text_animation)
					if step.text_reverse:
						text_anim.play(step.text_duration)
					else:
						text_anim.reverse()
					if step.text_duration > 0:
						await text_anim.finished
				hide()
				
func skip() -> void:
	if text_animator:
		text_animator.skip()


func close(animate: bool = false) -> void:
	if is_stopping:
		return
	is_stopping = true
	if animate:
		await animate_out()
