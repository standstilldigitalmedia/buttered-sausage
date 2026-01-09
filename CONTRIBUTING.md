# Contributing to Buttered Sausage

Thank you for your interest in contributing! This addon was developed with care and we'd love help making it even better.

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/standstilldigitalmedia/buttered-sausage/issues) to avoid duplicates
2. Include your Godot version (4.x)
3. Provide steps to reproduce
4. Share any error messages or logs
5. If possible, provide a minimal reproduction scene

### Suggesting Features

- Open an issue with the `enhancement` label
- Describe the use case and why it would be valuable
- Consider whether it fits the addon's scope (message display + result pattern)

### Contributing Code

#### Getting Started

1. Fork the repository
2. Clone your fork
3. Open the project in Godot 4.x
4. Run the demo scene: `addons/ButteredSausage/demo/buttered_sausage_demo.tscn`

#### Development Setup

**Testing Your Changes:**
- Use the included demo scene to test visual changes
- Add new demo scenarios if adding features
- Ensure existing functionality still works

**Code Style:**
- Follow GDScript style guide
- Use descriptive variable names
- Add doc comments for public methods (GDScript format with `##`)
- Keep functions focused and reasonably sized

#### Making Changes

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Test thoroughly using the demo scene
4. Commit with clear messages: `git commit -m "Add feature: description"`
5. Push to your fork: `git push origin feature/your-feature-name`
6. Open a Pull Request

#### Pull Request Guidelines

**Title:** Clear, concise description of the change
- ✅ "Fix rotation animation not playing on entry"
- ✅ "Add support for custom easing functions"
- ❌ "Update code"
- ❌ "Fix stuff"

**Description:** Include:
- What the change does
- Why it's needed (link to issue if applicable)
- How to test it
- Screenshots/GIFs for visual changes

**Before Submitting:**
- [ ] Tested in demo scene
- [ ] No errors in console
- [ ] Doc comments added/updated for public APIs
- [ ] Follows existing code style

## Priority Areas for Help

### 🔥 High Priority: Rotation Animation Bug

The rotation animation currently doesn't play when panels first appear. This is a tricky Godot tween issue we haven't cracked yet. See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) for details.

**Ideal Contributor:** Someone with deep knowledge of Godot's Tween system and angle interpolation

### Other Areas

- **Animation Presets:** More pre-configured animation resources
- **Documentation:** Tutorials, examples, video guides
- **Testing:** Edge cases, different Godot versions, different OS
- **Performance:** Profiling and optimization

## Code Structure

```
addons/ButteredSausage/
├── config/
│   ├── resource/         # Pre-configured .tres files
│   └── scripts/          # Configuration classes
├── demo/                 # Interactive demo scene
├── logic/               # Core result pattern (standalone)
├── ui/
│   ├── animator.gd      # Animation engine (standalone)
│   ├── display/         # Display manager
│   └── panel/           # Individual panels
└── utility/             # Helper scripts
```

**Standalone Components:**
- `logic/` - Result pattern (no dependencies)
- `ui/animator.gd` - Animation system (only needs config)
- These can be used independently of the full display system

## Questions?

- **General questions:** [GitHub Discussions](https://github.com/standstilldigitalmedia/buttered-sausage/discussions)
- **Bug reports:** [GitHub Issues](https://github.com/standstilldigitalmedia/buttered-sausage/issues)
- **Quick questions:** Open an issue tagged with `question`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping make Buttered Sausage better!** 🎉
