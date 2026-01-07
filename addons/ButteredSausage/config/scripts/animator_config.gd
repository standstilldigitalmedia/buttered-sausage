@tool
class_name ButteredSausageAnimatorConfig
extends Resource

enum Axis { VERTICAL, HORIZONTAL }
enum OpenDirection { POSITIVE, NEGATIVE }

@export_group("Direction")
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
@export var rotation_from: float = 0.0
@export var rotation_to: float = 0.0
@export var rotation_pivot: Vector2 = Vector2.ZERO

@export_group("Position")
@export var animate_position: bool = false
@export var position_offset: Vector2 = Vector2.ZERO

@export_group("Color")
@export var animate_color: bool = false
@export var color_from: Color = Color.WHITE
@export var color_to: Color = Color.WHITE

@export_group("Timing and Easing")
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease_type_open: Tween.EaseType = Tween.EASE_OUT
@export var ease_type_close: Tween.EaseType = Tween.EASE_IN
@export var animation_speed: float = 0.0

var panel_width: int
