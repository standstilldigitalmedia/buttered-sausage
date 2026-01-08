@tool
class_name ButteredSausageAnimatorConfig
extends Resource

enum Axis { VERTICAL, HORIZONTAL }
enum OpenDirection { POSITIVE, NEGATIVE }
enum RotationPivot { TOP_LEFT, TOP_CENTER, TOP_RIGHT, CENTER_LEFT, CENTER, CENTER_RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT, CUSTOM }

@export_group("Size Animation")
@export var animate_size: bool = true
@export var axis: Axis = Axis.VERTICAL
@export var open_direction: OpenDirection = OpenDirection.POSITIVE

@export_group("Scale")
@export var animate_scale: bool = false
@export var scale_from: Vector2 = Vector2(0.9, 0.9)
@export var scale_to: Vector2 = Vector2.ONE

@export_group("Fade")
@export var animate_fade: bool = false
@export var fade_from: float = 0.0
@export var fade_to: float = 1.0

@export_group("Rotation")
@export var animate_rotation: bool = false
@export var rotation_from_degrees: float = 0.0
@export var rotation_to_degrees: float = 0.0
@export var rotation_orbit: bool = false  ## If true, panel orbits around pivot. If false, spins in place.
@export var rotation_pivot_preset: RotationPivot = RotationPivot.CENTER
@export var rotation_pivot_custom: Vector2 = Vector2.ZERO

@export_group("Position")
@export var animate_position: bool = false
@export var position_offset: Vector2 = Vector2.ZERO

@export_group("Color")
@export var animate_color: bool = false
@export var color_from: Color = Color.WHITE
@export var color_to: Color = Color.WHITE

@export_group("Shake")
@export var animate_shake: bool = false
@export var shake_amount: float = 3.0
@export var shake_speed: float = 0.05

@export_group("Timing and Easing")
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease_type_open: Tween.EaseType = Tween.EASE_OUT
@export var ease_type_close: Tween.EaseType = Tween.EASE_IN
@export var animation_speed: float = 1.0

@export_group("Panel Sizing")
@export var panel_width: float = 400.0

@export_group("Loop Behavior")
@export var loop_animation: bool = false
