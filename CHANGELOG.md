# Changelog

All notable changes to Buttered Sausage will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
