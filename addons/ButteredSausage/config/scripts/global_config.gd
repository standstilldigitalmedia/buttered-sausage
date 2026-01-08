@tool
class_name ButteredSausageGlobalConfig
extends Resource

enum PositionPreset {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
}

@export var panel_width: float = 400.0

@export_group("Positioning")
@export var position_preset: PositionPreset = PositionPreset.TOP_RIGHT
@export var margin_from_edge: float = 20.0
@export var reverse_panel_order: bool = false  ## If true, new panels appear at the bottom instead of top

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
