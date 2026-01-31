## Configuration resource for ButteredSausagePanelAnimator.[br]
## Defines panel animation parameters including slide, scale, rotation, position, fade, color, and shake effects.[br][br]
##
## Dependencies: None. This is a standalone configuration resource.[br]
## Create via Resource menu and configure in the inspector.[br]
## Can be used independently of ButteredSausage for general UI animation.
class_name ButteredSausagePanelAnimatorConfig
extends Resource

enum Axis {
	VERTICAL,    ## Size animation expands/contracts vertically (top to bottom). Panel slides down when opening, up when closing.
	HORIZONTAL   ## Size animation expands/contracts horizontally (left to right). Panel slides right when opening, left when closing.
}

enum OpenDirection {
	POSITIVE,    ## Slide in the positive direction. For VERTICAL = downward, for HORIZONTAL = rightward.
	NEGATIVE     ## Slide in the negative direction. For VERTICAL = upward, for HORIZONTAL = leftward.
}

enum RotationPivot {
	TOP_LEFT,        ## Rotation/scale pivot at top-left corner of panel. Panel spins around this point.
	TOP_CENTER,      ## Rotation/scale pivot at top-center edge of panel. Creates a pendulum effect when rotating.
	TOP_RIGHT,       ## Rotation/scale pivot at top-right corner of panel. Panel spins around this point.
	CENTER_LEFT,     ## Rotation/scale pivot at center-left edge of panel. Panel rotates around its left side.
	CENTER,          ## Rotation/scale pivot at exact center of panel. Most common for spinning in place.
	CENTER_RIGHT,    ## Rotation/scale pivot at center-right edge of panel. Panel rotates around its right side.
	BOTTOM_LEFT,     ## Rotation/scale pivot at bottom-left corner of panel. Good for "falling leaf" effects.
	BOTTOM_CENTER,   ## Rotation/scale pivot at bottom-center edge of panel. Panel swings from this point.
	BOTTOM_RIGHT,    ## Rotation/scale pivot at bottom-right corner of panel. Good for corner spin effects.
	CUSTOM           ## Use custom pivot coordinates set in rotation_pivot_custom or scale_pivot_custom properties.
}

@export_group("Slide Out")
@export var animate_slide_out: bool = false  ## Enable size animation (slide/reveal effect). WARNING: Cannot combine with Scale, Rotation, or Position animations.
@export var axis: Axis = Axis.VERTICAL  ## Direction of size animation. VERTICAL = slides down/up, HORIZONTAL = slides left/right.
@export var open_direction: OpenDirection = OpenDirection.POSITIVE  ## Which way the panel slides. POSITIVE = down/right, NEGATIVE = up/left.

@export_group("Transform Animations")
@export_subgroup("Scale")
@export var animate_scale: bool = false  ## Enable scale animation (grow/shrink effect). Can combine with Rotation and Position.
@export var scale_from: Vector2 = Vector2(0.9, 0.9)  ## Starting scale (1.0 = normal size). Values less than 1.0 start small, greater than 1.0 start large.
@export var scale_to: Vector2 = Vector2.ONE  ## Ending scale (1.0 = normal size). Animation tweens from scale_from to scale_to.
@export var scale_pivot_preset: RotationPivot = RotationPivot.CENTER  ## Point around which scaling occurs. CENTER = grows from center, TOP_LEFT = grows from top-left corner, etc.
@export var scale_pivot_custom: Vector2 = Vector2.ZERO  ## Custom pivot point in pixels. Only used when scale_pivot_preset is CUSTOM.

@export_subgroup("Rotation")
@export var animate_rotation: bool = false  ## Enable rotation animation (spin effect). Can combine with Scale and Position.
@export var rotation_from_degrees: float = 0.0  ## Starting rotation angle in degrees (0 = no rotation). Example: -90 starts rotated left, 90 starts rotated right.
@export var rotation_to_degrees: float = 0.0  ## Ending rotation angle in degrees. Animation rotates from rotation_from to rotation_to. Use 360 for a full spin.
@export var rotation_orbit: bool = false  ## If true, panel orbits around pivot point while rotating. If false, spins in place at pivot.
@export var rotation_pivot_preset: RotationPivot = RotationPivot.CENTER  ## Point around which rotation occurs. CENTER = spins around center, corners = spins around that corner.
@export var rotation_pivot_custom: Vector2 = Vector2.ZERO  ## Custom pivot point in pixels from top-left. Only used when rotation_pivot_preset is CUSTOM.

@export_subgroup("Position")
@export var animate_position: bool = false  ## Enable position animation (move/slide effect). Can combine with Scale and Rotation.
@export var position_offset: Vector2 = Vector2.ZERO  ## Starting offset position in pixels. Positive X = starts right, negative X = starts left, same for Y. Animates to (0,0).

@export_group("Visual Effects")
@export_subgroup("Fade")
@export var animate_fade: bool = false  ## Enable fade animation (transparency effect). Fades the entire panel including text and icons. Safe to combine with transforms.
@export var fade_from: float = 0.0  ## Starting opacity (0.0 = invisible, 1.0 = fully visible). Typically start at 0.0 for a fade-in effect.
@export var fade_to: float = 1.0  ## Ending opacity (0.0 = invisible, 1.0 = fully visible). Animation tweens from fade_from to fade_to.

@export_subgroup("Color")
@export var animate_color: bool = false  ## Enable color animation (background color tween). Only affects panel background, not text or icons. Safe to combine with transforms.
@export var color_from: Color = Color.WHITE  ## Starting background color. Animation smoothly transitions from this color to color_to.
@export var color_to: Color = Color.WHITE  ## Ending background color. Use for effects like red flashing to normal, or white fade to colored.

@export_subgroup("Shake")
@export var animate_shake: bool = false  ## Enable shake animation (vibration effect). Adds random position offsets for emphasis. Safe to combine with other animations.
@export var shake_amount: float = 3.0  ## Maximum shake distance in pixels. Higher values = more aggressive shaking. Typical range: 2-10 pixels.
@export var shake_speed: float = 0.05  ## Time between shake updates in seconds. Lower = faster shaking. Typical range: 0.01-0.1 seconds.

@export_group("Timing and Easing")
@export var animation_speed: float = 1.0  ## Duration of animation in seconds. Lower = faster, higher = slower. Typical range: 0.2-2.0 seconds.
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC  ## Math curve for animation motion. CUBIC = smooth, LINEAR = constant speed, BOUNCE = bouncy, etc.
@export var ease_type_open: Tween.EaseType = Tween.EASE_OUT  ## Easing for opening animation. EASE_OUT = fast start/slow end (common for opens), EASE_IN = slow start/fast end.
@export var ease_type_close: Tween.EaseType = Tween.EASE_IN  ## Easing for closing animation. EASE_IN = slow start/fast end (common for closes), EASE_OUT = fast start/slow end.

@export_group("Panel Sizing")
@export var panel_width: float = 400.0  ## Panel width in pixels. Auto-populated by ButteredSausageDisplay. Generally don't modify this manually.
