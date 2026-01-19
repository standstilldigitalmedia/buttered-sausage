# Changelog

All notable changes to Buttered Sausage will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased - 2.0.0]

### Migration Notes

**BREAKING CHANGES** - This release requires code changes. See README.md "Upgrading from 1.0.x to 2.0.0" for detailed migration steps.

**New Dependency:** [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core) is now required. Install it via the Godot Asset Library or manually before upgrading.

**Result Pattern Migration:**
| Old (1.0.x) | New (2.0.0) |
|-------------|-------------|
| `ButteredSausage` | `SSDMResult` (from Standstill Core) |
| `ButteredSausageSeverity` | `SSDMSeverity.Level` (from Standstill Core) |

**Animation Chain Migration:**
| Old (1.0.x) | New (2.0.0) |
|-------------|-------------|
| `animation_chain` | `entrance_animation_chain` |
| `close_animation_chain` | `exit_animation_chain` |
| `Array[ButteredSausageAnimatorConfig]` | `Array[ButteredSausageAnimationStep]` |

### Added
- **Dependency:** [Standstill Core](https://github.com/standstilldigitalmedia/standstill-core) addon required for `SSDMResult` and `SSDMSeverity`
- `ButteredSausageAnimationStep` resource for per-step animation control
  - `animation` - Reference to a `ButteredSausageAnimatorConfig`
  - `reverse` - Play animation backwards
  - `loop` - Loop animation until panel closes
  - `delay_before` - Delay in seconds before starting step
- Icon color customization via `icon_modulate` property
- Close button text mode via `close_button_text` property
- Close button color customization via `close_button_modulate` property

### Changed
- **BREAKING:** Result pattern now uses `SSDMResult` and `SSDMSeverity` from Standstill Core
- **BREAKING:** `animation_chain` renamed to `entrance_animation_chain`
- **BREAKING:** `close_animation_chain` renamed to `exit_animation_chain`
- **BREAKING:** Animation chains now use `Array[ButteredSausageAnimationStep]` instead of `Array[ButteredSausageAnimatorConfig]`
- Existing panel configs must be recreated with AnimationStep wrappers

### Removed
- **BREAKING:** `ButteredSausage` class (use `SSDMResult` from Standstill Core)
- **BREAKING:** `ButteredSausageSeverity` enum (use `SSDMSeverity.Level` from Standstill Core)
- **BREAKING:** `loop_animation` property removed from `ButteredSausageAnimatorConfig` (moved to `ButteredSausageAnimationStep`)
- `logic/` folder removed (Result pattern now in Standstill Core)

## [1.0.1] - 2026-01-15

### Migration Notes

**Upgrading from 1.0.0:**

This release contains no breaking API changes. Existing scenes and scripts work without modification.

**IMPORTANT - Configuration Preservation:**
If you modified resource files (`.tres`) inside `addons/ButteredSausage/config/resource/`, those changes will be overwritten when you upgrade. To preserve custom configurations:

1. **Before upgrading:** Copy your custom `.tres` files to a folder OUTSIDE the addon (e.g., `res://config/buttered_sausage/`)
2. **Upgrade:** Extract 1.0.1 over your installation
3. **After upgrading:** Update your scenes to reference your custom config files instead of the defaults

**Best Practice:** Always create custom resource files in your project folders, not inside the addon folder. Treat addon files as read-only templates. See README.md "Best Practices for Custom Configurations" section for details.

### Fixed
- Rotation, Scale, and Position animations now work simultaneously without conflicts
- Size animation now works correctly when used alone
- Scene hierarchy restructured to use RotationIsolationLayer with proper layout modes
- Resource caching issues that prevented configuration changes from applying
- Color animations now preserve corner radius, border width, and border color styling
- Font color and font size configuration now apply correctly to RichTextLabel
- Font color no longer changes during color animations (animation now affects only background)
- Static style cache is now properly cleared on display initialization
- Demo script property reference corrected from `global_config` to `display_config`

### Changed
- License changed to CC0 1.0 Universal (Public Domain Dedication) for maximum freedom and recognition
- Updated documentation to reflect animation compatibility
- Removed `@tool` decorator from resource scripts to improve configuration reliability
- Color animations now tween stylebox `bg_color` property directly instead of modulating entire panel
- Resource script default values updated to be user-friendly

### Known Limitations
- Size animation cannot be combined with other transform animations (Rotation, Scale, Position)
- See KNOWN_ISSUES.md for details

## [1.0.0] - 2026-01-08

### Initial Release

#### Core Features
- Visual message display system with animated panels
- Result pattern (`ButteredSausage` class) for fluent error handling
- Severity levels: SUCCESS, INFO, WARNING, ERROR
- Complete documentation and interactive demo scene

#### Display Modes
- Unlimited panels mode (show all messages)
- Single panel mode with configurable priority-based display
- Limited mode with FIFO (First In First Out) panel management

#### User Experience
- Hover-to-pause functionality for auto-dismiss timers
- Manual close buttons on panels
- Duplicate message prevention
- Configurable panel positioning (9 screen positions)

#### Animation System
- Animation chains for complex sequential effects
- Multiple simultaneous effects: slide, scale, fade, rotation, position, color
- Shake effect for emphasis
- Configurable pivot points for rotation and scale
- Loop animations for persistent effects
- Three close behaviors: reverse first animation, mirror full chain, or no animation

#### Configuration
- Resource-based configuration system
- `ButteredSausageDisplayConfig` - Global display settings
- `ButteredSausagePanelConfig` - Per-severity panel styling and behavior
- `ButteredSausageAnimatorConfig` - Individual animation effects
- All settings editable via Inspector

#### Standalone Components
- `ButteredSausageSeverity` - Severity enum (no dependencies)
- `ButteredSausage` - Result pattern class (depends only on Severity)
- `ButteredSausageAnimator` - Control animation system (can animate any Control node)

#### API Highlights
- Builder pattern API for accumulating messages
- State conversion methods (success ↔ failure while preserving details)
- Result merging for nested operations
- Direct display methods: `show_success()`, `show_error()`, `show_warning()`, `show_info()`
- Integration method: `populate_from_result()`
