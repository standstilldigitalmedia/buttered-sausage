## Configuration resource for ButteredSausagePanel.[br]
## Defines visual styling, timing, and animation chains for message panels.[br][br]
##
## Used by ButteredSausageDisplay to configure panel appearance and behavior per severity level.
class_name ButteredSausagePanelConfig
extends Resource

enum Axis {
	VERTICAL,    ## Animation moves vertically (up/down direction)
	HORIZONTAL   ## Animation moves horizontally (left/right direction)
}

enum OpenDirection {
	POSITIVE,    ## Move in positive direction (down for vertical, right for horizontal)
	NEGATIVE     ## Move in negative direction (up for vertical, left for horizontal)
}

enum AnchorPresets {
	TopLeft,       ## Anchor panel to top-left position
	TopCenter,     ## Anchor panel to top-center position
	TopRight,      ## Anchor panel to top-right position
	CenterLeft,    ## Anchor panel to center-left position
	Center,        ## Anchor panel to exact center position
	CenterRight,   ## Anchor panel to center-right position
	BottomLeft,    ## Anchor panel to bottom-left position
	BottomCenter,  ## Anchor panel to bottom-center position
	BottomRight    ## Anchor panel to bottom-right position
}

enum Alignment {
	Left,     ## Align message text to the left edge of the panel
	Center,   ## Center message text within the panel (default, most common)
	Right,    ## Align message text to the right edge of the panel
	Justify   ## Stretch text to fill the width of the panel
}

enum CloseBehavior {
	REVERSE_FIRST_ANIMATION,  ## Play only the first animation from animation_chain in reverse when closing. Quick and clean.
	MIRROR_FULL_CHAIN,        ## Play all animations from animation_chain in reverse order when closing. Symmetrical open/close.
	NO_ANIMATION              ## Panel disappears instantly without any closing animation. Use for urgent dismissals.
}

@export_group("Background Color")
@export var background_color: Color = Color(0.2, 0.6, 0.2, 0.9)  ## Main background color for the panel. Color animations will tween this value if enabled.

@export_group("Text Alignment")
@export var label_text_alignment: Alignment = Alignment.Center  ## Horizontal alignment for message text within the panel (Left, Center, Right, or Justify).

@export_group("Font")
@export var font: Font  ## Custom font resource for message text. Leave empty to use default theme font.
@export var font_color: Color = Color(0.0, 0.0, 0.0, 1.0)  ## Color of the message text. Remains constant during color animations.
@export var font_size: int = 12  ## Size of the message text in pixels.

@export_group("Icon")
@export var hide_icon: bool = false  ## If true, no icon is displayed on the panel. If false, shows the icon texture on the left side.
@export var icon: Texture2D  ## Texture displayed as an icon on the left side of the panel (e.g., checkmark for success, X for error).
@export var icon_width: float = 24  ## Width of the icon display area in pixels.
@export var icon_height: float = 24  ## Height of the icon display area in pixels.

@export_group("Close Button")
@export var hide_close_button: bool = false  ## If true, removes the manual close button. Panel can only be dismissed via auto-dismiss timer.
@export var close_button_icon: Texture2D  ## Texture for the close button (typically an X icon). Appears on the right side of the panel.
@export var close_button_width: float = 24  ## Width of the close button in pixels.
@export var close_button_height: float = 24  ## Height of the close button in pixels.

@export_group("Border")
@export var border_color: Color = Color(0.1, 0.5, 0.1, 0.9)  ## Color of the panel border on all sides.
@export var top_width: int = 0  ## Border thickness for the top edge in pixels. 0 = no border.
@export var left_width: int = 0  ## Border thickness for the left edge in pixels. 0 = no border.
@export var bottom_width: int = 5  ## Border thickness for the bottom edge in pixels. 0 = no border.
@export var right_width: int = 3  ## Border thickness for the right edge in pixels. 0 = no border.

@export_group("Corner Radius")
@export var top_left_corner_radius: int = 4  ## Roundness of the top-left corner in pixels. 0 = sharp corner, higher = more rounded.
@export var top_right_corner_radius: int = 4  ## Roundness of the top-right corner in pixels. 0 = sharp corner, higher = more rounded.
@export var bottom_left_corner_radius: int = 4  ## Roundness of the bottom-left corner in pixels. 0 = sharp corner, higher = more rounded.
@export var bottom_right_corner_radius: int = 4  ## Roundness of the bottom-right corner in pixels. 0 = sharp corner, higher = more rounded.

@export_group("Margins")
@export var margin_top: int = 5  ## Internal padding between panel edge and content at the top in pixels.
@export var margin_left: int = 5  ## Internal padding between panel edge and content on the left in pixels.
@export var margin_bottom: int = 5  ## Internal padding between panel edge and content at the bottom in pixels.
@export var margin_right: int = 5  ## Internal padding between panel edge and content on the right in pixels.

@export_group("Auto-Dismiss Timing")
@export var auto_dismiss: bool = true  ## If true, panel automatically closes after duration seconds. If false, panel stays until manually closed.
@export var duration: float = 3.0  ## How long in seconds before the panel auto-dismisses. Timer pauses when mouse hovers over panel.

@export_group("Animation Chain")
@export var animation_chain: Array[ButteredSausageAnimatorConfig] = []  ## Sequence of animations played when panel opens. Animations play in array order. Leave empty for instant appearance.
@export var close_animation_chain: Array[ButteredSausageAnimatorConfig] = []  ## Custom animations for closing. If empty, uses close_behavior instead.
@export var close_behavior: CloseBehavior = CloseBehavior.REVERSE_FIRST_ANIMATION  ## How to animate closing when close_animation_chain is empty. Can reverse first animation, mirror full chain, or skip animation.

@export_group("Severity")
@export var severity: ButteredSausageSeverity.Level = ButteredSausageSeverity.Level.SUCCESS  ## Severity level this config applies to (SUCCESS, INFO, WARNING, or ERROR). Used for caching styleboxes and priority sorting.


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
