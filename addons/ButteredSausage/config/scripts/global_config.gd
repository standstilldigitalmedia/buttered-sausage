@tool
class_name ButteredSausageGlobalConfig
extends Resource

@export var panel_width: float = 400.0

@export_group("Panels")
@export var success_config: ButteredSausagePanelConfig
@export var error_config: ButteredSausagePanelConfig
@export var warning_config: ButteredSausagePanelConfig
@export var info_config: ButteredSausagePanelConfig

@export_group("Single Panel Mode")
## Priority values: Higher number = higher precedence. Set all equal for most-recent-wins behavior.
@export var use_single_panel_mode: bool = false
@export var error_priority: int = 3
@export var success_priority: int = 2
@export var warning_priority: int = 1
@export var info_priority: int = 0


func set_panel_width() -> void:
	for ani_config: ButteredSausageAnimatorConfig in success_config.animation_chain:
		ani_config.panel_width = panel_width
	for ani_config: ButteredSausageAnimatorConfig in error_config.animation_chain:
		ani_config.panel_width = panel_width
	for ani_config: ButteredSausageAnimatorConfig in warning_config.animation_chain:
		ani_config.panel_width = panel_width
	for ani_config: ButteredSausageAnimatorConfig in info_config.animation_chain:
		ani_config.panel_width = panel_width
