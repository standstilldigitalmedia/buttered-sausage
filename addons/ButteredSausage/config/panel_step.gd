class_name ButteredSausagePanelStep
extends Resource

@export_group("Panel Animation")
@export var panel_animation: ButteredSausagePanelAnimatorConfig  ## The panel animation configuration for this step. Leave null for no panel animation.
@export var panel_reverse: bool = false  ## If true, play the panel animation backwards (close-to-open direction).
@export var panel_loop: bool = false  ## If true, this panel animation loops continuously until the panel closes.

@export_group("Timing")
@export var delay_before: float = 0.0  ## Delay in seconds before starting this animation step.
