## Configuration resource for ButteredSausageDisplay.[br]
## Defines display positioning, panel width, panel limits, priorities, and per-severity panel configurations.[br][br]
##
## Used by ButteredSausageDisplay to configure the overall display system behavior.
class_name ButteredSausageDisplayConfig
extends Resource

enum PositionPreset {
	TOP_LEFT,        ## Position the panel container at the top-left corner. Panels stack downward from this point.
	TOP_CENTER,      ## Position the panel container at the top-center. Panels stack downward from this point.
	TOP_RIGHT,       ## Position the panel container at the top-right corner. Panels stack downward from this point.
	CENTER_LEFT,     ## Position the panel container at the center-left edge. Container centers vertically at this position.
	CENTER,          ## Position the panel container at the exact screen center. Container centers both horizontally and vertically.
	CENTER_RIGHT,    ## Position the panel container at the center-right edge. Container centers vertically at this position.
	BOTTOM_LEFT,     ## Position the panel container at the bottom-left corner. Panels stack upward from this point.
	BOTTOM_CENTER,   ## Position the panel container at the bottom-center. Panels stack upward from this point.
	BOTTOM_RIGHT     ## Position the panel container at the bottom-right corner. Panels stack upward from this point.
}

@export_group("Positioning")
@export var panel_width: float = 400.0  ## Width of each message panel in pixels. All panels in the display will use this width.
@export var position_preset: PositionPreset = PositionPreset.CENTER  ## Screen position where panels appear. Choose from 9 preset positions (corners, edges, center).
@export var margin_from_edge: float = 20.0  ## Distance in pixels between panels and the screen edge. Applies to all position presets.
@export var reverse_panel_order: bool = false  ## Stack direction for multiple panels. False = new panels at top, True = new panels at bottom.

@export_group("Panels")
@export var success_config: ButteredSausagePanelConfig  ## Visual styling and behavior for SUCCESS severity panels (green by default)
@export var error_config: ButteredSausagePanelConfig  ## Visual styling and behavior for ERROR severity panels (red by default)
@export var warning_config: ButteredSausagePanelConfig  ## Visual styling and behavior for WARNING severity panels (yellow by default)
@export var info_config: ButteredSausagePanelConfig  ## Visual styling and behavior for INFO severity panels (blue by default)

@export_group("Panel Limits")
## Maximum number of panels visible at once. 0 = unlimited panels, 1 = single panel mode (uses priority), 2+ = limited mode (FIFO removal when limit reached).
@export var max_visible_panels: int = 0
## Priority for ERROR panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var error_priority: int = 4
## Priority for SUCCESS panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var success_priority: int = 3
## Priority for WARNING panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var warning_priority: int = 2
## Priority for INFO panels in single panel mode (max_visible_panels = 1). Higher numbers win. Equal priorities favor most recent.
@export var info_priority: int = 1
