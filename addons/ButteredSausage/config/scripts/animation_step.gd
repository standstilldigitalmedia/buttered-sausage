## Wrapper resource for animation configuration with per-step control.[br]
## Allows reverse playback, looping, and delays for individual animation steps.[br][br]
##
## Used in entrance_animation_chain and exit_animation_chain arrays in ButteredSausagePanelConfig.
class_name ButteredSausageAnimationStep
extends Resource

@export var animation: ButteredSausageAnimatorConfig  ## The animation configuration to play for this step.
@export var reverse: bool = false  ## If true, play the animation backwards (close-to-open direction).
@export var loop: bool = false  ## If true, this animation loops continuously until the panel closes.
@export var delay_before: float = 0.0  ## Delay in seconds before starting this animation step.
