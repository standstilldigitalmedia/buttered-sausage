# Known Issues

## Rotation Animation Incompatible with Size Animation

**Severity:** Medium
**Component:** `ButteredSausageAnimator` (rotation animation)
**Status:** Workaround Available

### Description

Rotation animations conflict with size animations when both are enabled simultaneously on the same AnimatorConfig. The rotation pivot point becomes unstable as the container dimensions change during the size animation, causing erratic or non-functional rotation behavior.

### Root Cause

When `animate_size = true` and `animate_rotation = true` are both enabled:
- The size animation changes the wrapper Control's dimensions frame-by-frame
- This causes the rotation pivot point to shift during the animation
- The rotation tween becomes unstable or fails to play correctly

### Steps to Reproduce

1. Create a `ButteredSausageAnimatorConfig` with:
   - `animate_size = true`
   - `animate_rotation = true`
   - `rotation_from_degrees = 0.0`
   - `rotation_to_degrees = 360.0`
2. Add this config to a panel's animation chain
3. **Expected:** Panel should slide and rotate simultaneously
4. **Actual:** Rotation does not play correctly or appears erratic

### Workaround (Confirmed Working)

**Set `animate_size = false` when using rotation animations:**

```gdscript
# Working rotation config
animate_size = false        # Must be false
animate_rotation = true     # Rotation works perfectly when size is fixed
rotation_from_degrees = 0.0
rotation_to_degrees = 360.0
```

With a fixed-size container, rotation animations work flawlessly. You can still combine rotation with other animation types:
- ✅ Rotation + Fade
- ✅ Rotation + Scale
- ✅ Rotation + Position
- ✅ Rotation + Color
- ❌ Rotation + Size (known conflict)

### Future Plans

We haven't given up on making rotation and size animations work together. This is on the roadmap for a future update, but it requires deeper investigation into the interaction between container resizing and rotation pivot calculations. If you have expertise in this area and want to contribute a fix, we'd love your help!

### Alternative Approaches

If you specifically need both sliding (size change) AND rotation effects:
1. Use two separate AnimationStep entries in your chain:
   - Step 1: Size animation (slide in/out)
   - Step 2: Rotation animation with `animate_size = false`
2. Consider using scale + position animations as an alternative visual effect

---

**Related Files:**
- `addons/ButteredSausage/ui/animator.gd` - Animation logic
- `addons/ButteredSausage/config/scripts/animator_config.gd` - Configuration structure
- `addons/ButteredSausage/config/resource/animation/simple_rotate.tres` - Example rotation config

**Discussion:** [GitHub Issue #2](https://github.com/standstilldigitalmedia/buttered-sausage/issues/2)
