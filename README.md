# SSDM Error Display

A visual error/message display system for Godot 4.x with integrated Result pattern for fluent error handling.

## Overview

SSDM Error Display provides a complete solution for displaying operation results and messages in your Godot applications. It combines:

- **Visual Message Display** - Animated panels with severity-based styling (SUCCESS, INFO, WARNING, ERROR)
- **Result Pattern** - Type-safe error handling with builder pattern API for accumulating messages
- **Flexible Animations** - Configurable slide, scale, fade, rotation, and shake effects
- **Smart Display Modes** - Stack multiple messages or show only the highest priority

Perfect for editor tools, file managers, save systems, validation feedback, and any application that needs robust error reporting with visual polish.

## Features

### Visual Display System
- Color-coded severity levels with smooth animations
- Message stacking or single-message (priority) modes
- Auto-dismiss for non-error messages
- Manual close buttons
- Severity-specific animations (errors shake, warnings bounce, etc.)

### Result Pattern
- Fluent builder API for accumulating warnings and info messages
- State conversion (success → failure, etc.) while preserving details
- Merge results from nested operations
- Type-safe with full autocomplete support

### Animation System
- Multiple effects: slide, scale, fade, rotation, bounce, elastic, spring
- Configurable pivot points for rotation
- Parallel animation composition
- Shake effect for emphasis

## Why "SSDM"?

All classes use the `SSDM` prefix (Standstill Digital Media) to avoid naming conflicts with other addons. GDScript doesn't have namespaces, so this ensures type safety and autocomplete work reliably:

```gdscript
@export var display: SSDMErrorDisplay
var result := SSDMResult.success("Operation completed!")
```

**Curious about SSDM?** This addon was originally developed as part of the [AWOC (Avatar Wardrobe Organizer and Colorer)](https://github.com/standstill-interactive/awoc) system, where robust error handling and user feedback were essential.

## Installation

### Via Asset Library (Recommended)
1. Open Godot Editor
2. Go to **AssetLib** tab
3. Search for "SSDM Error Display"
4. Click **Download** → **Install**
5. Enable the plugin in **Project Settings → Plugins**

### Manual Installation
1. Download the latest release
2. Copy the `addons/SSDMErrorDisplay/` folder to your project's `addons/` directory
3. Enable the plugin in **Project Settings → Plugins**

## Quick Start

### Basic Usage

Add an `SSDMErrorDisplay` node to your scene:

```gdscript
extends Control

@onready var error_display: SSDMErrorDisplay = $ErrorDisplay

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
func save_file(path: String) -> SSDMResult:
	var result := SSDMResult.success("File saved successfully")

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
var result := SSDMResult.success("Batch operation completed")
result.with_info("Processed 47 files")
result.with_warning("Skipped 2 locked files")
result.with_warning("Failed to delete temporary cache")
error_display.populate_from_result(result)
```

**State Conversion** - Change success to failure while keeping details:
```gdscript
var result := SSDMResult.success("Processing files...")
result.with_info("Loaded config.json")
result.with_info("Validated 15 entries")

if critical_error_occurred():
	result.to_failure("Process halted due to critical error")

error_display.populate_from_result(result)
```

**Merge Pattern** - Combine results from nested operations:
```gdscript
var parent_result := SSDMResult.success("Batch operation in progress")

# Sub-operation 1
var child1 := process_first_batch()
parent_result.merge_from(child1)

# Sub-operation 2
var child2 := process_second_batch()
parent_result.merge_from(child2)

error_display.populate_from_result(parent_result)
```

## Configuration

### Display Modes

**Stacking Mode** (default) - Show all messages:
```gdscript
error_display.set_stacking_enabled(true)
```

**Priority Mode** - Show only the highest severity message:
```gdscript
error_display.set_stacking_enabled(false)
```

### Customizing Colors and Timing

You can customize colors, timings, and styling directly through the Inspector by selecting your `SSDMErrorDisplay` node. All configuration options are exposed as exported variables organized in groups:

- **Auto-Dismiss Timing** - Control how long each severity level displays before auto-dismissing
- **Panel Colors** - Customize background and border colors for each severity level
- **Panel Style** - Adjust corner radius and border widths

Alternatively, you can set them programmatically:
```gdscript
error_display.success_duration = 5.0
error_display.success_color = Color(0.3, 0.8, 0.3, 0.95)
```

Default timings:
- **SUCCESS**: 3 seconds
- **WARNING**: 4 seconds
- **INFO**: 6 seconds
- **ERROR**: 6 seconds (manual dismiss)

### Custom Animations

Create your own animation profiles by configuring the `SSDMSlideAnimator`:

```gdscript
var animator := SSDMSlideAnimator.new(wrapper, panel)
animator.configure(SSDMSlideAnimator.Axis.VERTICAL, SSDMSlideAnimator.OpenDirection.POSITIVE) \
	.with_scale(Vector2(0.8, 0.8)) \
	.with_fade() \
	.with_bounce() \
	.with_speed(0.5)
animator.slide_open()
```

## API Reference

### SSDMErrorDisplay

**Main Methods:**
- `show_success(message: String)` - Display success message (auto-dismiss)
- `show_warning(message: String)` - Display warning message (auto-dismiss)
- `show_info(message: String)` - Display info message (auto-dismiss)
- `show_error(message: String)` - Display error message (manual dismiss)
- `populate_from_result(result: SSDMResult)` - Display all messages from a Result object
- `clear_all_panels()` - Close all message panels
- `set_stacking_enabled(enabled: bool)` - Toggle between stacking/priority modes

### SSDMResult

**Factory Methods:**
- `SSDMResult.success(msg: String, data: Variant = null)` - Create success result
- `SSDMResult.failure(msg: String, data: Variant = null, error: Error = FAILED)` - Create failure result
- `SSDMResult.warning(msg: String, data: Variant = null)` - Create warning result
- `SSDMResult.info(msg: String, data: Variant = null)` - Create info result

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
- `merge_from(other: SSDMResult, takeover_message: bool = true)` - Merge another result
- `has_details() -> bool` - Check if result has detail messages
- `is_success() -> bool` - Check if result represents success

## Examples

See the included demo scene at `demo/error_display_demo.tscn` for interactive examples including:
- Basic message display
- Result pattern usage
- Accumulator pattern
- State conversion
- Merge pattern
- Validation with multiple errors

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
