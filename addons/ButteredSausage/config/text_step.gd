class_name ButteredSausageTextStep
extends Resource

@export_group("Text Animation")
@export var text_animation: ButteredSausageTextAnimatorConfig  ## The text animation configuration for this step. Leave null for no text animation.
@export var text_reverse: bool = false  ## If true, play the text animation backwards.
@export var text_duration: float = 0.0  ## Duration for continuous text effects (wave/shake/glitch/rainbow/pulse). 0 = infinite for continuous effects, natural duration for typewriter/apparate/crawl.

@export_group("Timing")
@export var delay_before: float = 0.0  ## Delay in seconds before starting this animation step.
