@tool
class_name ButteredSausageConfig
extends Resource

@export var slide_speed: float = 0.3
@export_group("Panel Colors")
@export var success_color: Color = Color(0.2, 0.6, 0.2, 0.9)
@export var success_border_color: Color = Color(0.1, 0.5, 0.1, 0.9)
@export var info_color: Color = Color(0.2, 0.4, 0.8, 0.9)
@export var info_border_color: Color = Color(0.1, 0.3, 0.7, 0.9)
@export var warning_color: Color = Color(0.8, 0.6, 0.1, 0.9)
@export var warning_border_color: Color = Color(0.7, 0.5, 0.0, 0.9)
@export var error_color: Color = Color(0.8, 0.2, 0.2, 0.9)
@export var error_border_color: Color = Color(0.7, 0.1, 0.1, 0.9)

@export_group("Auto-Dismiss Timing")
@export var success_duration: float = 3.0
@export var warning_duration: float = 4.0
@export var info_duration: float = 6.0
@export var error_duration: float = 6.0

@export_group("Panel Style")
@export var corner_radius: int = 4
@export var border_width_bottom: int = 5
@export var border_width_left: int = 3
@export var panel_width: int = 400
