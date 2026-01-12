@tool
## Configuration resource for ButteredSausageDisplay.[br]
## Defines display positioning, panel width, panel limits, priorities, and per-severity panel configurations.[br][br]
##
## Used by ButteredSausageDisplay to configure the overall display system behavior.
class_name ButteredSausageDisplayConfig
extends Resource

enum PositionPreset {
	TOP_LEFT,        ## Top-left corner
	TOP_CENTER,      ## Top center
	TOP_RIGHT,       ## Top-right corner
	CENTER_LEFT,     ## Center left
	CENTER,          ## Center screen
	CENTER_RIGHT,    ## Center right
	BOTTOM_LEFT,     ## Bottom-left corner
	BOTTOM_CENTER,   ## Bottom center
	BOTTOM_RIGHT     ## Bottom-right corner
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

@export_group("Panel Limits")
## Maximum number of visible panels. 0 = unlimited, 1 = single panel mode. When limit is reached, oldest panels are auto-dismissed.
@export var max_visible_panels: int = 0
## Priority values for single panel mode (max_visible_panels = 1). Higher number = higher priority. In case of tie, most recent wins.
@export var error_priority: int = 3
@export var success_priority: int = 2
@export var warning_priority: int = 1
@export var info_priority: int = 0
