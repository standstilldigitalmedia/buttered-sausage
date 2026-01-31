## Wrapper resource for animation configuration with per-step control.[br]
## Allows configuring both panel and text animations for each step in an animation chain.[br][br]
##
## Panel and text animations play simultaneously within a step.[br]
## For sequential animations, create separate steps.[br]
## Used in entrance_animation_chain and exit_animation_chain arrays in ButteredSausagePanelConfig.
class_name ButteredSausageAnimationStep
extends Resource

@export_group("Panel Animation")
@export var panel_animation: ButteredSausagePanelAnimatorConfig  ## The panel animation configuration for this step. Leave null for no panel animation.
@export var panel_reverse: bool = false  ## If true, play the panel animation backwards (close-to-open direction).
@export var panel_loop: bool = false  ## If true, this panel animation loops continuously until the panel closes.

@export_group("Text Animation")
@export var text_animation: ButteredSausageTextAnimatorConfig  ## The text animation configuration for this step. Leave null for no text animation.
@export var text_reverse: bool = false  ## If true, play the text animation backwards.
@export var text_duration: float = 0.0  ## Duration for continuous text effects (wave/shake/glitch/rainbow/pulse). 0 = infinite for continuous effects, natural duration for typewriter/apparate/crawl.

@export_group("Timing")
@export var delay_before: float = 0.0  ## Delay in seconds before starting this animation step.
