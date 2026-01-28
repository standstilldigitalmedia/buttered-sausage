## Configuration resource for ButteredSausageAnimator.[br]
## Defines animation parameters including size, scale, fade, rotation, position, color, and shake effects.[br][br]
##
## Dependencies: None. This is a standalone configuration resource.[br]
## Create via Resource menu and configure in the inspector.
class_name ButteredSausageAnimatorConfig
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

@export_group("Text Effects")
@export_subgroup("Typewriter")
@export var animate_typewriter: bool = false  ## Enable typewriter effect. Text appears character by character like a typing animation.
@export var characters_per_second: float = 30.0  ## Speed of typewriter effect. Higher = faster typing. 30 is a natural reading pace.
@export var skip_on_click: bool = true  ## If true, clicking the panel completes the typewriter animation instantly.

@export_subgroup("Apparate")
@export var animate_text_apparate: bool = false  ## Enable apparate effect. Text materializes with a mystical scattered fade, like magic.
@export var apparate_duration: float = 1.5  ## Total duration for the apparate effect in seconds.
@export var apparate_spread: float = 0.15  ## Width of the fade gradient. Higher = softer transition.

@export_subgroup("Wave")
@export var animate_text_wave: bool = false  ## Enable wave effect. Text undulates in a wave pattern. Continuous effect.
@export var wave_horizontal: bool = false  ## If true, wave moves text left/right. If false, wave moves text up/down.
@export var wave_amplitude: float = 0.03  ## Height of the wave. Higher = more dramatic wave motion.
@export var wave_frequency: float = 10.0  ## Number of waves across the text. Higher = more compressed waves.
@export var wave_speed: float = 3.0  ## Speed of wave animation. Higher = faster wave motion.
@export var wave_duration: float = 0.0  ## Duration before wave fades out. 0 = infinite, >0 = fade out over this many seconds.

@export_subgroup("Text Shake")
@export var animate_text_shake: bool = false  ## Enable text shake effect. Text jitters randomly. Continuous effect.
@export var text_shake_amount: float = 0.02  ## Intensity of shake. Higher = more aggressive jitter.
@export var text_shake_speed: float = 20.0  ## Speed of shake updates. Higher = faster jitter.
@export var text_shake_duration: float = 0.0  ## Duration before shake fades out. 0 = infinite, >0 = fade out over this many seconds.

@export_subgroup("Glitch")
@export var animate_text_glitch: bool = false  ## Enable glitch effect. Digital corruption with slice displacement and RGB separation. Continuous effect.
@export var glitch_intensity: float = 0.5  ## How often and how strong glitches occur. 0.0 = rare/subtle, 1.0 = constant/intense.
@export var glitch_speed: float = 5.0  ## Speed of glitch updates. Higher = faster flickering.
@export var glitch_block_size: float = 0.1  ## Size of horizontal slice blocks. Smaller = more slices.
@export var glitch_color_drift: float = 0.02  ## RGB channel separation amount. Higher = more chromatic aberration.
@export var glitch_duration: float = 0.0  ## Duration before glitch fades out. 0 = infinite, >0 = fade out over this many seconds.

@export_subgroup("Rainbow")
@export var animate_text_rainbow: bool = false  ## Enable rainbow effect. Text cycles through colors. Continuous effect.
@export var rainbow_frequency: float = 1.0  ## Color cycles across text width. Higher = more color bands.
@export var rainbow_speed: float = 1.0  ## Speed of color cycling. Higher = faster color shift.
@export var rainbow_saturation: float = 1.0  ## Color intensity. 1.0 = vivid, 0.0 = grayscale.

@export_subgroup("Pulse")
@export var animate_text_pulse: bool = false  ## Enable pulse effect. Text fades in and out rhythmically. Continuous effect.
@export var pulse_speed: float = 2.0  ## Speed of pulsing. Higher = faster pulse.
@export var pulse_min_alpha: float = 0.3  ## Minimum opacity during pulse. 0.0 = fully transparent at lowest.

@export_subgroup("Crawl")
@export var animate_text_crawl: bool = false  ## Enable crawl effect. Star Wars style scrolling text. NOTE: Does not combine well with Rotation animation due to clipping limitations.
@export var crawl_height: float = 72.0  ## Viewport height in pixels. Default is ~3 lines of text.
@export var crawl_speed: float = 30.0  ## Scroll speed in pixels per second.
@export var crawl_perspective: float = 0.0  ## PLANNED FEATURE (not yet implemented). Amount of perspective narrowing at top. 0.0 = none, 1.0 = extreme.
@export var crawl_fade_height: float = 0.3  ## Portion of top that fades out. 0.0-1.0 of viewport height.

@export_group("Timing and Easing")
@export var animation_speed: float = 1.0  ## Duration of animation in seconds. Lower = faster, higher = slower. Typical range: 0.2-2.0 seconds.
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC  ## Math curve for animation motion. CUBIC = smooth, LINEAR = constant speed, BOUNCE = bouncy, etc.
@export var ease_type_open: Tween.EaseType = Tween.EASE_OUT  ## Easing for opening animation. EASE_OUT = fast start/slow end (common for opens), EASE_IN = slow start/fast end.
@export var ease_type_close: Tween.EaseType = Tween.EASE_IN  ## Easing for closing animation. EASE_IN = slow start/fast end (common for closes), EASE_OUT = fast start/slow end.

@export_group("Panel Sizing")
@export var panel_width: float = 400.0  ## Panel width in pixels. Auto-populated by ButteredSausageDisplay. Generally don't modify this manually.
