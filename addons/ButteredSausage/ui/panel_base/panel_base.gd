@tool
## A generic animated panel component.[br]
## Handles panel styling (stylebox, borders, corners, margins) and entrance/exit animations.[br][br]
##
## Extend this class to build toast panels, menus, dialogues, or any animated UI.
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



enum CloseBehavior {
	REVERSE_FIRST_ANIMATION,  ## Play only the first animation from entrance_animation_chain in reverse when closing. Quick and clean.
	MIRROR_FULL_CHAIN,        ## Play all animations from entrance_animation_chain in reverse order when closing. Symmetrical open/close.
	NO_ANIMATION              ## Panel disappears instantly without any closing animation. Use for urgent dismissals.
}

@export_group("Background Color")
@export var background_color: Color = Color(0.2, 0.6, 0.2, 0.9)  ## Main background color for the panel. Color animations will tween this value if enabled.

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

@export_group("Animation Chains")
@export var entrance_animation_chain: Array[ButteredSausagePanelStep] = []  ## Sequence of animation steps played when panel opens. Each step wraps an AnimatorConfig with optional reverse, loop, and delay. Leave empty for instant appearance.
@export var exit_animation_chain: Array[ButteredSausagePanelStep] = []  ## Custom animation steps for closing. If empty, uses close_behavior instead.
@export var close_behavior: CloseBehavior = CloseBehavior.REVERSE_FIRST_ANIMATION  ## How to animate closing when exit_animation_chain is empty. Can reverse first animation, mirror full chain, or skip animation.

@export_group("Control")
@export var rotation_container: Control
@export var panel_container: PanelContainer
@export var margin_container: MarginContainer

var is_closing: bool = false


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
	

## Applies the panel configuration to all UI elements.[br]
## Sets styling, fonts, colors, icons, margins, and mouse filters.[br][br]
func configure() -> void:
	var style_box: StyleBox = create_stylebox()
	panel_container.add_theme_stylebox_override(PANEL_THEME, style_box)
	margin_container.add_theme_constant_override("margin_left", margin_left)
	margin_container.add_theme_constant_override("margin_top", margin_top)
	margin_container.add_theme_constant_override("margin_right", margin_right)
	margin_container.add_theme_constant_override("margin_bottom", margin_bottom)

	# Set mouse filters so child controls don't interfere with hover detection
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Animates the panel into view using the configured animation chain.[br]
## Supports optional animation looping until panel closes.[br][br]
func open() -> void:
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
	for step in entrance_animation_chain:
		# Skip steps with no animations assigned
		if not step.panel_animation:
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

		if step.panel_animation:
			panel_anim = ButteredSausagePanelAnimator.new(self, panel_container, rotation_container)
			panel_anim.configure(step.panel_animation)

		if panel_anim:
			if step.panel_reverse:
				# For looping animations, don't hide after reverse (they need to stay visible for the loop)
				panel_anim.reverse(not step.panel_loop)
			else:
				panel_anim.play()

		if panel_anim:
			await panel_anim.finished

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
	if animate:
		await slide_closed()
		
		
func _ready() -> void:
	configure()
