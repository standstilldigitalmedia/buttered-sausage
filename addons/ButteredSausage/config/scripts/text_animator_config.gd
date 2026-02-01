## Configuration resource for ButteredSausageTextAnimator.[br]
## Defines text animation parameters including typewriter, apparate, wave, shake, glitch, rainbow, pulse, and crawl effects.[br][br]
##
## Dependencies: None. This is a standalone configuration resource.[br]
## Create via Resource menu and configure in the inspector.[br]
## Can be used independently of ButteredSausage panels for dialogue systems, RPG text, etc.
class_name ButteredSausageTextAnimatorConfig
extends Resource

@export_group("Typewriter")
@export var animate_typewriter: bool = false  ## Enable typewriter effect. Text appears character by character like a typing animation.
@export var characters_per_second: float = 30.0  ## Speed of typewriter effect. Higher = faster typing. 30 is a natural reading pace.
@export var skip_on_click: bool = true  ## If true, clicking completes the typewriter animation instantly.

@export_group("Apparate")
@export var animate_text_apparate: bool = false  ## Enable apparate effect. Text materializes with a mystical scattered fade, like magic.
@export var apparate_speed: float = 0.7  ## Speed of apparate effect. Higher = faster materialization.
@export var apparate_spread: float = 1.0  ## Width of the fade gradient. Higher = softer transition.

@export_group("Wave")
@export var animate_text_wave: bool = false  ## Enable wave effect. Text undulates in a wave pattern. Continuous effect.
@export var wave_horizontal: bool = false  ## If true, wave moves text left/right. If false, wave moves text up/down.
@export var wave_amplitude: float = 0.03  ## Height of the wave. Higher = more dramatic wave motion.
@export var wave_frequency: float = 10.0  ## Number of waves across the text. Higher = more compressed waves.
@export var wave_speed: float = 3.0  ## Speed of wave animation. Higher = faster wave motion.

@export_group("Text Shake")
@export var animate_text_shake: bool = false  ## Enable text shake effect. Text jitters randomly. Continuous effect.
@export var text_shake_amount: float = 0.02  ## Intensity of shake. Higher = more aggressive jitter.
@export var text_shake_speed: float = 20.0  ## Speed of shake updates. Higher = faster jitter.

@export_group("Glitch")
@export var animate_text_glitch: bool = false  ## Enable glitch effect. Digital corruption with slice displacement and RGB separation. Continuous effect.
@export var glitch_intensity: float = 0.5  ## How often and how strong glitches occur. 0.0 = rare/subtle, 1.0 = constant/intense.
@export var glitch_speed: float = 5.0  ## Speed of glitch updates. Higher = faster flickering.
@export var glitch_block_size: float = 0.1  ## Size of horizontal slice blocks. Smaller = more slices.
@export var glitch_color_drift: float = 0.02  ## RGB channel separation amount. Higher = more chromatic aberration.

@export_group("Rainbow")
@export var animate_text_rainbow: bool = false  ## Enable rainbow effect. Text cycles through colors. Continuous effect.
@export var rainbow_frequency: float = 1.0  ## Color cycles across text width. Higher = more color bands.
@export var rainbow_speed: float = 1.0  ## Speed of color cycling. Higher = faster color shift.
@export var rainbow_saturation: float = 1.0  ## Color intensity. 1.0 = vivid, 0.0 = grayscale.

@export_group("Pulse")
@export var animate_text_pulse: bool = false  ## Enable pulse effect. Text fades in and out rhythmically. Continuous effect.
@export var pulse_speed: float = 2.0  ## Speed of pulsing. Higher = faster pulse.
@export var pulse_min_alpha: float = 0.3  ## Minimum opacity during pulse. 0.0 = fully transparent at lowest.

@export_group("Crawl")
@export var animate_text_crawl: bool = false  ## Enable crawl effect. Star Wars style scrolling text.
@export var crawl_height: float = 72.0  ## Viewport height in pixels. Default is ~3 lines of text.
@export var crawl_speed: float = 30.0  ## Scroll speed in pixels per second.
@export var crawl_fade_height: float = 0.3  ## Portion of top that fades out. 0.0-1.0 of viewport height.
