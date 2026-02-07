# Buttered Sausage

A visual error/message display system for Godot 4.x with integrated Result pattern for fluent error handling.

![Buttered Sausage in Action](screenshots/buttered_sausage_animation.gif)

### Screenshots

![Message Display](screenshots/display1.png)
*Multiple severity levels with auto-dismiss and manual close options*

![Configuration](screenshots/config.png)
*Fully customizable via Inspector - each panel scene has its own settings*

## Overview

Buttered Sausage provides a complete solution for displaying operation results and messages in your Godot applications. It combines:

- **Visual Message Display** - Animated panels with severity-based styling (SUCCESS, INFO, WARNING, ERROR)
- **Result Pattern** - Type-safe error handling with builder pattern API for accumulating messages
- **Flexible Animations** - Configurable slide, scale, fade, rotation, and shake effects with animation chains
- **Scene-Based Configuration** - Each severity has its own panel scene, fully editable in the Inspector
- **Smart Display Modes** - Stack multiple messages or show only the highest priority

Perfect for editor tools, file managers, save systems, validation feedback, and any application that needs robust error reporting with visual polish.

## Features

### Visual Display System
- Color-coded severity levels with smooth animations
- Configurable panel limits (unlimited, single panel, or custom max)
- Auto-dismiss for non-error messages with hover-to-pause
- Manual close buttons
- Animation chains for complex sequences
- Loop animations for persistent effects

### Result Pattern
- Fluent builder API for accumulating warnings and info messages
- State conversion (success → failure, etc.) while preserving details
- Merge results from nested operations
- Consistent return pattern for functions with data payload
- Type-safe with full autocomplete support
- Standalone - can be used without the UI/display components

### Animation System
- Animation chains - sequential series of effects
- **Transform animations work together:** Rotation, Scale, and Position can all animate simultaneously
- Multiple simultaneous effects: slide, scale, fade, rotation, color, position
- Shake effect for emphasis
- Configurable pivot points for rotation and scale
- Full control over timing, easing, and transitions
- Support for looping animations
- Standalone panel animator (`ButteredSausagePanelAnimator` + `ButteredSausagePanelAnimatorConfig`) can be used to animate any Control node
- Standalone text animator (`ButteredSausageTextAnimator` + `ButteredSausageTextAnimatorConfig`) can be used for dialogue systems, RPG text, or any text animation needs
- **Note:** Size animation cannot be combined with transform animations (see KNOWN_ISSUES.md)

### Configuration System
- **ButteredSausageDisplay** - Display positioning, panel width, and severity panel scene references (configured directly on the node)
- **Panel Scenes** - Each severity has its own scene (`success.tscn`, `error.tscn`, etc.) with colors, fonts, icons, borders, timing, and animation chains
- **ButteredSausagePanelAnimatorConfig** - Panel animation effects (slide, scale, rotation, etc.) as reusable Resources
- **ButteredSausageTextAnimatorConfig** - Text animation effects (typewriter, wave, glitch, etc.) as reusable Resources
- Display and panel settings editable directly in the Inspector on scenes

## Why "Buttered Sausage"?

All classes use the `ButteredSausage` prefix to avoid naming conflicts with other addons. GDScript doesn't have namespaces, so this ensures type safety and autocomplete work reliably:

```gdscript
@export var display: ButteredSausageDisplay
var result := ButteredSausage.success("Operation completed!")
```

**About the name:** I asked my wife, Liz, to help name a "result and toast addon." She was probably thinking about breakfast when she blurted out "Buttered Sausage." We looked at each other and just started giggling. The name stuck. It's silly, memorable, and avoids namespace collisions. That's it - just harmless fun, not meant to be anything else.

## Installation

### Prerequisites

Buttered Sausage 2.0.0+ requires [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core) (SSDM Core). Install it first.

### Via Asset Library (Recommended)
1. Open Godot Editor
2. Go to **AssetLib** tab
3. Search for "Standstill Core" and install it
4. Search for "Buttered Sausage" and install it

### Manual Installation
1. Download [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core) and copy `addons/SSDMCore/` to your project's `addons/` directory
2. Download the latest Buttered Sausage release
3. Copy the `addons/ButteredSausage/` folder to your project's `addons/` directory

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

The Result pattern (`SSDMResult` class + `SSDMSeverity` enum from [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core)) can be used standalone without the display system or integrated with visual feedback.

**Dependencies:** Requires Standstill Core addon. Only uses `SSDMResult` and `SSDMSeverity` - no UI components needed.

**Standalone Usage:**
```gdscript
func process_data() -> SSDMResult:
	var result := SSDMResult.success("Processing complete")

	if some_warning:
		result.with_warning("Minor issue detected")

	if critical_error:
		result.to_failure("Failed to process")

	return result

# Check result without displaying
func _ready() -> void:
	var result := process_data()
	if result.is_success():
		print("Success: ", result.message)
	else:
		print("Failed: ", result.message)
```

**Integrated with Display:**

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

## Important Notes

### Message Deduplication

Buttered Sausage prevents duplicate messages from spamming the display. When creating a message, it checks all existing panels and won't create a new one if an identical message already exists (based on exact string comparison).

**Warning:** Avoid using dynamic strings that change with each call:

```gdscript
# BAD - Creates a new panel every time because the string is different
error_display.show_error("The name: " + name_input.text + " is invalid")

# GOOD - Uses a static message, won't create duplicates
error_display.show_error("Invalid name format")
```

This is especially important when validating text input in real-time (e.g., listening to `text_changed` signals). Use generic, static messages to avoid panel spam.

## Configuration

### Best Practices for Custom Configurations

**IMPORTANT:** To preserve your custom configurations when upgrading Buttered Sausage, follow these best practices:

1. **Create your own panel scenes OUTSIDE the addon folder:**
   - Create a folder in your project: `res://scenes/buttered_sausage/` or similar
   - Duplicate the panel scenes from `res://addons/ButteredSausage/ui/panel/` to your project folder
   - Modify your copies, not the originals in the addon folder

2. **Reference your custom scenes in the display:**
   - Select your `ButteredSausageDisplay` node
   - In the Inspector, assign your custom panel scenes to `success_panel`, `error_panel`, `warning_panel`, `info_panel`

3. **For animation configs, copy them outside the addon:**
   - Animation configs (`.tres` files in `config/resource/animation/`) are still Resources
   - Copy any you want to customize to your project folder

4. **Treat addon files as read-only:**
   - The files in `addons/ButteredSausage/` are templates and will be overwritten during upgrades
   - Your custom scenes and configs outside the addon folder will be preserved

**Why this matters:** When you upgrade to a new version by extracting the addon over the old one, all files in `addons/ButteredSausage/` are replaced. Any modifications you made to files inside the addon folder will be lost.

### Upgrading from 1.0.x to 2.0.0

**BREAKING CHANGES** - Version 2.0.0 introduces significant changes that require code updates.

**1. Install Standstill Core (New Dependency)**

Buttered Sausage 2.0.0 requires [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core). Install it via the Asset Library or manually before upgrading.

**2. Update Result Pattern References**

The Result pattern classes have moved to Standstill Core:

| Old (1.0.x) | New (2.0.0) |
|-------------|-------------|
| `ButteredSausage` | `SSDMResult` |
| `ButteredSausageSeverity` | `SSDMSeverity.Level` |

Find and replace in your scripts:
```gdscript
# Old
var result := ButteredSausage.success("Done")
result.with_detail("Info", ButteredSausageSeverity.INFO)

# New
var result := SSDMResult.success("Done")
result.with_detail("Info", SSDMSeverity.Level.INFO)
```

**3. Update Animation Chain Properties**

| Old (1.0.x) | New (2.0.0) |
|-------------|-------------|
| `animation_chain` | `entrance_animation_chain` |
| `close_animation_chain` | `exit_animation_chain` |

**4. Recreate Animation Chains with AnimationStep Wrappers**

Animation chains now use `Array[ButteredSausageAnimationStep]` instead of `Array[ButteredSausageAnimatorConfig]`. Each `ButteredSausageAnimationStep` wraps an `AnimatorConfig` with additional per-step controls:

- `animation` - The `ButteredSausageAnimatorConfig` resource
- `reverse` - Play animation backwards
- `loop` - Loop until panel closes (moved from `AnimatorConfig`)
- `delay_before` - Delay before starting this step

**5. Migrate to Scene-Based Configuration**

The configuration system has changed from Resources to Scenes:

| Old (1.0.x) | New (2.0.0) |
|-------------|-------------|
| `ButteredSausageDisplayConfig` resource | Properties directly on `ButteredSausageDisplay` node |
| `ButteredSausagePanelConfig` resource | Properties directly on panel scenes |
| Single `panel.tscn` + config `.tres` files | Separate panel scenes per severity |
| `display_config` export | `success_panel`, `error_panel`, `warning_panel`, `info_panel` exports |

**Migration steps:**
1. Your `ButteredSausageDisplay` node no longer has a `display_config` property
2. Configure display settings (position, margins, panel limits) directly on the `ButteredSausageDisplay` node
3. Assign panel scenes to `success_panel`, `error_panel`, `warning_panel`, `info_panel`
4. To customize panel appearance, duplicate the panel scenes to your project folder and modify them

**6. Recreate Animation Chains**

If you have custom animation chains:
1. Create new `ButteredSausageAnimationStep` resources for each animation
2. Assign your existing `ButteredSausageAnimatorConfig` to the `animation` property
3. Set `loop` on the step instead of the config (if using looping)
4. Add steps to `entrance_animation_chain` on your panel scenes

### Upgrading from 1.0.0 to 1.0.1

If you modified the default resource files in `addons/ButteredSausage/config/resource/` during 1.0.0:

1. **Before upgrading:** Copy your modified `.tres` files to a safe location outside the addon folder
2. **Upgrade:** Extract 1.0.1 over your existing installation
3. **After upgrading:** Your custom `.tres` files outside the addon are safe. If you modified files inside the addon, re-apply your changes by:
   - Opening your saved copies
   - Comparing them to the new defaults
   - Recreating your custom configs in your project folder (not in the addon folder)

**What changed in 1.0.1:**
- Added comprehensive Inspector tooltips (hover over any property for detailed help)
- Fixed resource caching issues
- Fixed color animation styling preservation
- Fixed font color/size configuration
- No breaking API changes - existing scenes and scripts work without modification

### Display Setup

The `ButteredSausageDisplay` node comes pre-configured with sensible defaults. To customize the display, select the `ButteredSausageDisplay` node in your scene and edit properties directly in the Inspector.

**ButteredSausageDisplay** properties:

*Positioning:*
- `panel_width` - Width of all message panels (default: 400)
- `position_preset` - Screen position (TOP_RIGHT, BOTTOM_LEFT, etc.)
- `margin_from_edge` - Distance from screen edges (default: 20)
- `reverse_panel_order` - New panels appear at bottom instead of top

*Panels:*
- `success_panel` - PackedScene for success messages
- `error_panel` - PackedScene for error messages
- `warning_panel` - PackedScene for warning messages
- `info_panel` - PackedScene for info messages

*Panel Limits:*
- `max_visible_panels` - Maximum number of visible panels (0 = unlimited)
- `error_priority`, `success_priority`, `warning_priority`, `info_priority` - Priority values for single panel mode (higher = higher priority)

### Panel Limits

The `max_visible_panels` setting controls how many panels can be displayed simultaneously:

**Unlimited Mode** (default) - Show all messages:
```gdscript
# In Inspector: set max_visible_panels = 0
```

**Single Panel Mode** - Show only the highest priority message:
```gdscript
# In Inspector: set max_visible_panels = 1
# Uses priority values (default: ERROR=4, SUCCESS=3, WARNING=2, INFO=1)
# In case of tie, most recent message wins
```

**Limited Mode** - Show up to N messages:
```gdscript
# In Inspector: set max_visible_panels = 5
# When limit is reached, oldest panels are automatically dismissed (FIFO)
```

### Panel Configuration

Each severity level has its own panel scene (found in `res://addons/ButteredSausage/ui/panel/`) with extensive customization options. Open a panel scene and select the root node to edit properties in the Inspector:

**Visual Styling:**
- `background_color` - Panel background color
- `border_color`, `top_width`, `left_width`, `bottom_width`, `right_width` - Border styling
- `top_left_corner_radius`, etc. - Corner radius for each corner
- `font`, `font_color`, `font_size` - Text styling
- `label_text_alignment` - Text alignment (Left, Center, Right, Justify)

**Icons and Buttons:**
- `icon`, `icon_width`, `icon_height` - Severity icon
- `icon_modulate` - Icon color tint
- `hide_icon` - Hide the severity icon
- `close_button_icon`, `close_button_width`, `close_button_height` - Close button styling
- `close_button_text` - Use text instead of icon for close button
- `close_button_modulate` - Close button color tint
- `hide_close_button` - Hide the close button

**Timing:**
- `auto_dismiss` - Enable automatic dismissal
- `duration` - Seconds before auto-dismiss (default: 3.0 for success)
- **Hover-to-Pause:** Auto-dismiss timers automatically pause when the user hovers their mouse over a panel, allowing them time to read longer messages. The timer resumes when the mouse exits the panel.

**Animation Chains:**
- `entrance_animation_chain` - Array of `ButteredSausageAnimationStep` for opening animations
- `exit_animation_chain` - Array of `ButteredSausageAnimationStep` for custom closing animations
- `close_behavior` - Default closing behavior when `exit_animation_chain` is empty:
  - `REVERSE_FIRST_ANIMATION` (default) - Reverses the first animation from `entrance_animation_chain`
  - `MIRROR_FULL_CHAIN` - Reverses entire `entrance_animation_chain` in reverse order
  - `NO_ANIMATION` - Hides immediately without animation

### Animation Configuration

Unlike the display and panel configurations (which are pre-created), you'll create your own `ButteredSausageAnimatorConfig` resources for custom animations.

**Recommended Method - Duplicate an Existing Config:**

1. Navigate to `res://addons/ButteredSausage/config/resource/animation/`
2. Right-click on a config file similar to what you want to create → **Duplicate**
3. Enter a new name and click **OK**
4. Move the new config to a folder outside the addon directory (e.g., `res://config/buttered_sausage/`)
5. Modify and save

**Alternative Method - Create from Scratch:**

1. Right-click in the FileSystem panel → **New Resource**
2. Select **Resource** (empty resource)
3. Save it with a descriptive name (e.g., `slide_fade_in.tres`)
4. In the Inspector, click the **Script** property and select `res://addons/ButteredSausage/config/scripts/panel_animator_config.gd`
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
- `scale_pivot_preset` - Pivot point for scaling (CENTER, TOP_LEFT, BOTTOM_RIGHT, etc.)
- `scale_pivot_custom` - Custom pivot point if using CUSTOM preset
- **Note:** If both scale and rotation animations are enabled, the rotation pivot takes precedence since rotation is typically more sensitive to pivot placement.

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
- ⚠️ **Note:** Rotation works perfectly with Scale and Position. However, Size animation cannot be combined with transform animations. See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for details.

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

### Animation Steps

Animation chains use `ButteredSausageAnimationStep` resources to wrap `ButteredSausageAnimatorConfig` with per-step control:

**ButteredSausageAnimationStep Properties:**
- `animation` - The `ButteredSausageAnimatorConfig` to play for this step
- `reverse` - Play the animation backwards (close-to-open direction)
- `loop` - Loop this animation continuously until the panel closes
- `delay_before` - Delay in seconds before starting this animation step

### Animation Chains

Animation chains allow you to create complex sequential animations. Each step in the chain plays one after another:

```
Example chain:
1. Slide down + fade in (0.3 seconds)
2. Scale bounce effect (0.2 seconds)
3. Subtle shake for emphasis (0.4 seconds, looping)
```

After creating your animation configs, wrap them in `ButteredSausageAnimationStep` resources and add them to the `entrance_animation_chain` array on your panel scene. The display will:
1. Play each animation step sequentially
2. If any step has `loop = true`, continuously loop those animations
3. Stop looping when the panel closes

For closing animations, you have multiple options:
1. **Custom exit chain** - Define an `exit_animation_chain` with specific closing animations (takes precedence)
2. **Default behavior** - When `exit_animation_chain` is empty, use the `close_behavior` setting:
   - `REVERSE_FIRST_ANIMATION` - Reverses only the first animation (default, fastest)
   - `MIRROR_FULL_CHAIN` - Reverses entire entrance chain in reverse order (mirrors open)
   - `NO_ANIMATION` - Hides immediately without animation (instant dismiss)

## API Reference

### Standalone Components

These components can be used independently without the full display system:

**SSDMSeverity** (from [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core)) - Severity level enum
- **Dependencies:** Standstill Core addon
- **Usage:** Define message severity levels
- **Levels:** `SSDMSeverity.Level.SUCCESS`, `SSDMSeverity.Level.INFO`, `SSDMSeverity.Level.WARNING`, `SSDMSeverity.Level.ERROR`

**SSDMResult** (from [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core)) - Result pattern class
- **Dependencies:** Standstill Core addon
- **Usage:** Encapsulate operation results with messages, errors, data payload and accumulated details

**ButteredSausagePanelAnimator** - Panel animation system
- **Dependencies:** `ButteredSausagePanelAnimatorConfig`
- **Usage:** Animate any Control node with slides, scales, fades, rotations, colors, and positions

**ButteredSausageTextAnimator** - Text animation system
- **Dependencies:** `ButteredSausageTextAnimatorConfig`
- **Usage:** Animate RichTextLabel nodes with typewriter, apparate, wave, shake, glitch, rainbow, pulse, and crawl effects

### Full Display System

**ButteredSausageDisplay**

**Main Methods:**
- `show_success(message: String)` - Display success message (auto-dismiss)
- `show_warning(message: String)` - Display warning message (auto-dismiss)
- `show_info(message: String)` - Display info message (auto-dismiss)
- `show_error(message: String)` - Display error message (manual dismiss)
- `populate_from_result(result: SSDMResult)` - Display all messages from a Result object
- `clear_all_panels()` - Close all message panels

**SSDMResult** (from [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core))

**Factory Methods:**
- `SSDMResult.success(msg: String, data: Variant = null)` - Create success result
- `SSDMResult.failure(msg: String, data: Variant = null, error: Error = FAILED)` - Create failure result
- `SSDMResult.warning(msg: String, data: Variant = null)` - Create warning result
- `SSDMResult.info(msg: String, data: Variant = null)` - Create info result

**Builder Methods:**
- `with_detail(msg: String, severity: SSDMSeverity.Level)` - Add detail message
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

See the included demo scene at `addons/ButteredSausage/demo/buttered_sausage_demo.tscn` for interactive examples including:
- Basic message display
- Result pattern usage
- Accumulator pattern
- State conversion
- Merge pattern
- Validation with multiple errors
- Various animation configurations

## Known Issues

**Size Animation Limitation:** Size animation cannot be combined with transform animations (Rotation, Scale, Position) in the same AnimatorConfig. See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for technical details.

**Good news:** Rotation, Scale, and Position all work together perfectly! You can combine all three for complex transform effects.

## Part of the AWOC Ecosystem

This addon was developed as part of [AWOC (Avatar Wardrobe Organizer and Colorer)](https://github.com/standstilldigitalmedia/AWOC), a comprehensive avatar customization system for Godot. Check out AWOC if you need:
- Advanced avatar customization
- Wardrobe management
- Color overlay system with material management
- Modular character systems

## License

CC0 1.0 Universal (Public Domain Dedication) - See LICENSE file for details

This means you can do whatever you want with this software. No attribution required, no restrictions, no copyright.

## Credits

Developed by [Standstill Digital Media](https://github.com/standstilldigitalmedia/)

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

Report bugs via [Github Issues](https://github.com/standstilldigitalmedia/buttered-sausage/issues)

Ask questions in [Github Discussions](https://github.com/standstilldigitalmedia/buttered-sausage/discussions)
