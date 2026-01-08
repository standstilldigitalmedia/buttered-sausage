@tool
## Configuration resource for ButteredSausagePanel.[br]
## Defines visual styling, timing, and animation chains for message panels.[br][br]
##
## Used by ButteredSausageDisplay to configure panel appearance and behavior per severity level.
class_name ButteredSausagePanelConfig
extends Resource

enum Axis { VERTICAL, HORIZONTAL }  ## Animation axis
enum OpenDirection { POSITIVE, NEGATIVE }  ## Animation direction
enum AnchorPresets {TopLeft, TopCenter, TopRight, CenterLeft, Center, CenterRight, BottomLeft, BottomCenter, BottomRight}  ## Panel anchor points
enum Alignment {Left, Center, Right, Justify}  ## Text alignment options
enum CloseBehavior {
	REVERSE_FIRST_ANIMATION,  ## Reverse the first animation from animation_chain
	MIRROR_FULL_CHAIN,        ## Reverse entire animation_chain in reverse order
	NO_ANIMATION              ## Hide immediately without animation
}

@export_group("Background Color")
@export var background_color: Color = Color(0.2, 0.6, 0.2, 0.9)

@export_group("Text Alignment")
@export var label_text_alignment: Alignment = Alignment.Center

@export_group("Font")
@export var font: Font
@export var font_color: Color = Color(0.0, 0.0, 0.0, 1.0)
@export var font_size: int = 12

@export_group("Icon")
@export var hide_icon: bool = false
@export var icon: Texture2D
@export var icon_width: float = 24
@export var icon_height: float = 24

@export_group("Close Button")
@export var hide_close_button: bool = false
@export var close_button_icon: Texture2D
@export var close_button_width: float = 24
@export var close_button_height: float = 24

@export_group("Border")
@export var border_color: Color = Color(0.1, 0.5, 0.1, 0.9)
@export var top_width: int = 0
@export var left_width: int = 0
@export var bottom_width: int = 5
@export var right_width: int = 3

@export_group("Corner Radius")
@export var top_left_corner_radius: int = 4
@export var top_right_corner_radius: int = 4
@export var bottom_left_corner_radius: int = 4
@export var bottom_right_corner_radius: int = 4

@export_group("Margins")
@export var margin_top: int = 5
@export var margin_left: int = 5
@export var margin_bottom: int = 5
@export var margin_right: int = 5

@export_group("Auto-Dismiss Timing")
@export var auto_dismiss: bool = true
@export var duration: float = 3.0

@export_group("Animation Chain")
@export var animation_chain: Array[ButteredSausageAnimatorConfig] = []
@export var close_animation_chain: Array[ButteredSausageAnimatorConfig] = []
@export var close_behavior: CloseBehavior = CloseBehavior.REVERSE_FIRST_ANIMATION

@export_group("Severity")
@export var severity: ButteredSausageSeverity.Level = ButteredSausageSeverity.Level.SUCCESS


## Creates a StyleBoxFlat from the configured visual properties.[br][br]
##
## @return A StyleBoxFlat with configured colors, borders, and corner radii[br]
func create_stylebox() -> StyleBox:
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = background_color
	style_box.corner_radius_top_left = top_left_corner_radius
	style_box.corner_radius_top_right = top_right_corner_radius
	style_box.corner_radius_bottom_left = bottom_left_corner_radius
	style_box.corner_radius_bottom_right = bottom_right_corner_radius
	style_box.border_color = border_color
	style_box.border_width_top = top_width
	style_box.border_width_left = left_width
	style_box.border_width_bottom = bottom_width
	style_box.border_width_right = right_width
	return style_box
