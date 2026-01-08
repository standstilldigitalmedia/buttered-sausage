# Buttered Sausage

A visual error/message display system for Godot 4.x with integrated Result pattern for fluent error handling.

## Overview

Buttered Sausage provides a complete solution for displaying operation results and messages in your Godot applications. It combines:

- **Visual Message Display** - Animated panels with severity-based styling (SUCCESS, INFO, WARNING, ERROR)
- **Result Pattern** - Type-safe error handling with builder pattern API for accumulating messages
- **Flexible Animations** - Configurable slide, scale, fade, rotation, and shake effects with animation chains
- **Resource-Based Configuration** - Fully customizable via inspector-editable Resource files
- **Smart Display Modes** - Stack multiple messages or show only the highest priority

Perfect for editor tools, file managers, save systems, validation feedback, and any application that needs robust error reporting with visual polish.

## Features

### Visual Display System
- Color-coded severity levels with smooth animations
- Message stacking or single-message (priority) modes
- Auto-dismiss for non-error messages
- Manual close buttons
- Animation chains for complex sequences
- Loop animations for persistent effects

### Result Pattern
- Fluent builder API for accumulating warnings and info messages
- State conversion (success → failure, etc.) while preserving details
- Merge results from nested operations
- Type-safe with full autocomplete support

### Animation System
- Animation chains - sequential series of effects
- Multiple simultaneous effects: slide, scale, fade, rotation, color, position
- Shake effect for emphasis
- Configurable pivot points for rotation
- Full control over timing, easing, and transitions
- Support for looping animations

### Configuration System
- **ButteredSausageGlobalConfig** - Global positioning, panel width, and per-severity configurations
- **ButteredSausagePanelConfig** - Colors, fonts, icons, borders, timing, and animation chains
- **ButteredSausageAnimatorConfig** - Individual animation effects with full customization
- All configurations are Resources editable in the Inspector

## Why "Buttered Sausage"?

All classes use the `ButteredSausage` prefix to avoid naming conflicts with other addons. GDScript doesn't have namespaces, so this ensures type safety and autocomplete work reliably:

```gdscript
@export var display: ButteredSausageDisplay
var result := ButteredSausage.success("Operation completed!")
```

**Curious about the name?** This addon was originally developed as part of the [AWOC (Avatar Wardrobe Organizer and Colorer)](https://github.com/standstill-interactive/awoc) system, where robust error handling and user feedback were essential. The original prefix was "SSDM" (Standstill Digital Media), but has been rebranded to Buttered Sausage for wider release.

## Installation

### Via Asset Library (Recommended)
1. Open Godot Editor
2. Go to **AssetLib** tab
3. Search for "Buttered Sausage"
4. Click **Download** → **Install**
5. Enable the plugin in **Project Settings → Plugins**

### Manual Installation
1. Download the latest release
2. Copy the `addons/ButteredSausage/` folder to your project's `addons/` directory
3. Enable the plugin in **Project Settings → Plugins**

## Quick Start

### Basic Usage

Add a `ButteredSausageDisplay` node to your scene:

```gdscript
extends Control

@onready var error_display: ButteredSausageDisplay = $ErrorDisplay

func _ready() -> void:
	# Show a simple success message
	error_display.show_success("File saved successfully!")

	# Show an error that requires dismissal
	error_display.show_error("Failed to load configuration file")

	# Show a warning with auto-dismiss
	error_display.show_warning("Network connection unstable")
```

### Using the Result Pattern

The real power comes from combining visual display with the Result pattern:

```gdscript
func save_file(path: String) -> ButteredSausage:
	var result := ButteredSausage.success("File saved successfully")

	# Accumulate warnings during operation
	if not has_write_permission(path):
		result.with_warning("Limited write permissions")

	if file_exists(path):
		result.with_info("Overwrote existing file")

	# Convert to failure if something critical happens
	if disk_full():
		result.to_failure("Save failed - disk full")

	return result

func _on_save_pressed() -> void:
	var result := save_file("user://config.dat")
	error_display.populate_from_result(result)
```

### Builder Pattern Examples

**Accumulator Pattern** - Build up messages as you go:
```gdscript
var result := ButteredSausage.success("Batch operation completed")
result.with_info("Processed 47 files")
result.with_warning("Skipped 2 locked files")
result.with_warning("Failed to delete temporary cache")
error_display.populate_from_result(result)
```

**State Conversion** - Change success to failure while keeping details:
```gdscript
var result := ButteredSausage.success("Processing files...")
result.with_info("Loaded config.json")
result.with_info("Validated 15 entries")

if critical_error_occurred():
	result.to_failure("Process halted due to critical error")

error_display.populate_from_result(result)
```

**Merge Pattern** - Combine results from nested operations:
```gdscript
var parent_result := ButteredSausage.success("Batch operation in progress")

# Sub-operation 1
var child1 := process_first_batch()
parent_result.merge_from(child1)

# Sub-operation 2
var child2 := process_second_batch()
parent_result.merge_from(child2)

error_display.populate_from_result(parent_result)
```

## Configuration

### Display Setup

The `ButteredSausageDisplay` node comes pre-configured with all necessary resources. To customize the display, open `res://addons/ButteredSausage/config/resource/main/global_config.tres` in the Inspector. This file contains a `ButteredSausageGlobalConfig` resource with sensible defaults and references to all severity-specific panel configurations.

**ButteredSausageGlobalConfig** properties:
- `panel_width` - Width of all message panels (default: 400)
- `position_preset` - Screen position (TOP_RIGHT, BOTTOM_LEFT, etc.)
- `margin_from_edge` - Distance from screen edges (default: 20)
- `reverse_panel_order` - New panels appear at bottom instead of top
- `use_single_panel_mode` - Show only highest priority message
- `success_config`, `error_config`, `warning_config`, `info_config` - Per-severity panel configurations

### Display Modes

**Stacking Mode** (default) - Show all messages:
```gdscript
# In Inspector: set global_config.use_single_panel_mode = false
# Or programmatically:
error_display.set_stacking_enabled(true)
```

**Priority Mode** - Show only the highest severity message:
```gdscript
# In Inspector: set global_config.use_single_panel_mode = true
# Or programmatically:
error_display.set_stacking_enabled(false)
```

### Panel Configuration

Each severity level has its own pre-configured `ButteredSausagePanelConfig` resource (found in `res://addons/ButteredSausage/config/resource/panels/`) with extensive customization options. Open these .tres files in the Inspector to customize:

**Visual Styling:**
- `background_color` - Panel background color
- `border_color`, `top_width`, `left_width`, `bottom_width`, `right_width` - Border styling
- `top_left_corner_radius`, etc. - Corner radius for each corner
- `font`, `font_color`, `font_size` - Text styling
- `label_text_alignment` - Text alignment (Left, Center, Right, Justify)

**Icons and Buttons:**
- `icon`, `icon_width`, `icon_height` - Severity icon
- `hide_icon` - Hide the severity icon
- `close_button_icon`, `close_button_width`, `close_button_height` - Close button styling
- `hide_close_button` - Hide the close button

**Timing:**
- `auto_dismiss` - Enable automatic dismissal
- `duration` - Seconds before auto-dismiss (default: 3.0 for success)

**Animation Chains:**
- `animation_chain` - Array of `ButteredSausageAnimatorConfig` for opening animations
- `close_animation_chain` - Array of `ButteredSausageAnimatorConfig` for closing animations
- `mirror_full_open_chain_on_close` - Reverse the open chain for closing

### Animation Configuration

Unlike the global and panel configurations (which are pre-created), you'll create your own `ButteredSausageAnimatorConfig` resources for custom animations. To create one:

1. Right-click in the FileSystem panel → **New Resource**
2. Select **Resource** (empty resource)
3. Save it with a descriptive name (e.g., `slide_fade_in.tres`)
4. In the Inspector, click the **Script** property and select `res://addons/ButteredSausage/config/scripts/animator_config.gd`
5. Configure the animation properties

Each config can enable multiple effects simultaneously:

**Size Animation:**
- `animate_size` - Enable size animation (slide effect)
- `axis` - VERTICAL or HORIZONTAL
- `open_direction` - POSITIVE (down/right) or NEGATIVE (up/left)

**Scale Animation:**
- `animate_scale` - Enable scale effect
- `scale_from` - Starting scale (e.g., Vector2(0.9, 0.9))
- `scale_to` - Ending scale (e.g., Vector2.ONE)

**Fade Animation:**
- `animate_fade` - Enable fade effect
- `fade_from` - Starting alpha (0.0 = invisible)
- `fade_to` - Ending alpha (1.0 = opaque)

**Rotation Animation:**
- `animate_rotation` - Enable rotation effect
- `rotation_from_degrees`, `rotation_to_degrees` - Rotation angles
- `rotation_orbit` - True for orbital rotation, false for spinning in place
- `rotation_pivot_preset` - Pivot point (CENTER, TOP_LEFT, BOTTOM_RIGHT, etc.)
- `rotation_pivot_custom` - Custom pivot point if using CUSTOM preset

**Position Animation:**
- `animate_position` - Enable position offset effect
- `position_offset` - Starting position offset (animates to Vector2.ZERO)

**Color Animation:**
- `animate_color` - Enable color tween effect
- `color_from` - Starting color
- `color_to` - Ending color

**Shake Animation:**
- `animate_shake` - Enable shake effect (ignores other animations)
- `shake_amount` - Horizontal shake distance
- `shake_speed` - Speed of each shake oscillation

**Timing and Easing:**
- `transition_type` - Tween transition (TRANS_CUBIC, TRANS_SINE, etc.)
- `ease_type_open` - Easing for opening (EASE_OUT, EASE_IN_OUT, etc.)
- `ease_type_close` - Easing for closing (EASE_IN, EASE_IN_OUT, etc.)
- `animation_speed` - Duration in seconds

**Loop Behavior:**
- `loop_animation` - Loop this animation after chain completes

### Animation Chains

Animation chains allow you to create complex sequential animations. Each config in the chain plays one after another:

```
Example chain:
1. Slide down + fade in (0.3 seconds)
2. Scale bounce effect (0.2 seconds)
3. Subtle shake for emphasis (0.4 seconds)
```

After creating your animation configs, add them to the `animation_chain` array in your `ButteredSausagePanelConfig` (found in `res://addons/ButteredSausage/config/resource/panels/`). The display will:
1. Play each animation sequentially
2. If any animation has `loop_animation = true`, continuously loop those animations
3. Stop looping when the panel closes

For closing animations, you have three options:
1. Define a custom `close_animation_chain`
2. Set `mirror_full_open_chain_on_close = true` to reverse the entire opening chain
3. Use the default (reverses only the first animation in the chain)

## API Reference

### ButteredSausageDisplay

**Main Methods:**
- `show_success(message: String)` - Display success message (auto-dismiss)
- `show_warning(message: String)` - Display warning message (auto-dismiss)
- `show_info(message: String)` - Display info message (auto-dismiss)
- `show_error(message: String)` - Display error message (manual dismiss)
- `populate_from_result(result: ButteredSausage)` - Display all messages from a Result object
- `clear_all_panels()` - Close all message panels
- `set_stacking_enabled(enabled: bool)` - Toggle between stacking/priority modes

### ButteredSausage (Result Class)

**Factory Methods:**
- `ButteredSausage.success(msg: String, data: Variant = null)` - Create success result
- `ButteredSausage.failure(msg: String, data: Variant = null, error: Error = FAILED)` - Create failure result
- `ButteredSausage.warning(msg: String, data: Variant = null)` - Create warning result
- `ButteredSausage.info(msg: String, data: Variant = null)` - Create info result

**Builder Methods:**
- `with_detail(msg: String, severity: Severity)` - Add detail message
- `with_warning(msg: String)` - Add warning detail
- `with_info(msg: String)` - Add info detail
- `with_error(msg: String, err: Error = FAILED)` - Add error detail

**State Conversion:**
- `to_success(msg: String = "")` - Convert to success
- `to_failure(msg: String = "", err: Error = FAILED)` - Convert to failure
- `to_warning(msg: String = "")` - Convert to warning
- `to_info(msg: String = "")` - Convert to info

**Utility Methods:**
- `merge_from(other: ButteredSausage, takeover_message: bool = true)` - Merge another result
- `has_details() -> bool` - Check if result has detail messages
- `is_success() -> bool` - Check if result represents success

## Examples

See the included demo scene at `addons/ButteredSausage/demo/buttered_sausage_demo.tscn` for interactive examples including:
- Basic message display
- Result pattern usage
- Accumulator pattern
- State conversion
- Merge pattern
- Validation with multiple errors
- Various animation configurations

## Part of the AWOC Ecosystem

This addon was developed as part of [AWOC (Avatar Wardrobe Organizer and Colorer)](https://github.com/standstilldigitalmedia/AWOC), a comprehensive avatar customization system for Godot. Check out AWOC if you need:
- Advanced avatar customization
- Wardrobe management
- Color palette systems
- Modular character systems

## License

MIT License - See LICENSE file for details

## Credits

Developed by [Standstill Digital Media](https://standstilldigitalmedia.com)

## Contributing

Issues and pull requests welcome! Visit the [GitHub repository](https://github.com/standstilldigitalmedia/buttered-sausage) to contribute.

## Support

Report bugs via [Github Issues](https://github.com/standstilldigitalmedia/buttered-sausage/issues)
Ask questions in [Github Discussions](https://github.com/standstilldigitalmedia/buttered-sausage/discussions)