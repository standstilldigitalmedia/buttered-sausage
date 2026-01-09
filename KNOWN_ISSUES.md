# Known Issues

## Rotation Animation Not Playing on Panel Entry

**Severity:** Medium
**Component:** `ButteredSausageAnimator` (rotation animation)
**Status:** Help Wanted

### Description

Rotation animations configured in `ButteredSausageAnimatorConfig` do not play when a panel first appears (entry animation). The animation only plays during the exit/dismissal phase.

### Steps to Reproduce

1. Open the demo scene: `addons/ButteredSausage/demo/buttered_sausage_demo.tscn`
2. Click "Show Warning" button (which uses the rotate animation)
3. **Expected:** Panel should rotate smoothly as it appears
4. **Actual:** Panel appears instantly without rotation
5. Wait for auto-dismiss or click close button
6. **Observed:** Panel rotates correctly during exit animation

### Configuration Details

**Animation Config:** `res://addons/ButteredSausage/config/resource/animation/simple_rotate.tres`
```gdscript
animate_size = false
animate_rotation = true
rotation_from_degrees = 0.0
rotation_to_degrees = 360.0
```

**Panel Config:** `res://addons/ButteredSausage/config/resource/panel/warning_config.tres`
- Uses `simple_rotate.tres` in its `animation_chain`
- `close_behavior = REVERSE_FIRST_ANIMATION` (default)

### Technical Details

The issue appears to be related to Godot's angle normalization in the tween system. Several approaches have been attempted:

1. **Using `.from()` with explicit values** - Godot normalizes 360° (2π) to 0°, making from/to the same value
2. **Using `.as_relative()`** - Doesn't trigger the animation on entry
3. **Calculating current + delta** - Still subject to normalization
4. **Using Godot's TAU constant** - Tried using TAU (2π) directly instead of deg_to_rad(360), but tween still doesn't animate

**Current Implementation:** `addons/ButteredSausage/ui/animator.gd:216-226` (forward) and `287-298` (reverse)

### Observations

- Exit/reverse animation works correctly
- Animation works for non-full-rotation values (e.g., 300°), but displays the final rotated state immediately, then animates in reverse on exit
- Other animation types (scale, fade, position, etc.) work as expected
- The rotation initial state setup (lines 178-186) appears correct

### Looking for Help

If you have experience with Godot's Tween system and rotation animations, we'd appreciate your insight! This is likely a simple fix for someone familiar with the nuances of angle interpolation in Godot 4.x.

**Ways to Help:**
- Review `addons/ButteredSausage/ui/animator.gd` (specifically the `play()` and `reverse()` methods)
- Test with different Godot 4.x versions
- Suggest alternative approaches for handling rotation tweens
- Submit a PR with a fix

### Workarounds

For now, if you need rotation animations:
1. Consider using scale + position animations as an alternative effect
2. Use the rotation animation only in `close_animation_chain` where it works correctly

---

**Related Files:**
- `addons/ButteredSausage/ui/animator.gd` - Animation logic
- `addons/ButteredSausage/config/scripts/animator_config.gd` - Configuration structure
- `addons/ButteredSausage/config/resource/animation/simple_rotate.tres` - Example rotation config

**Discussion:** [Link to issue when created]
