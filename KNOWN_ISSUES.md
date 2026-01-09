# Known Issues

## Rotation Animation Incompatible with Size and Position Animations

**Severity:** Medium
**Component:** `ButteredSausageAnimator` (rotation animation)
**Status:** Workaround Available

### Description

Rotation animations conflict with size and position animations when enabled simultaneously on the same AnimatorConfig. The rotation pivot point becomes unstable as the container dimensions or position change during the animation, causing erratic or non-functional rotation behavior.

### Root Cause

When rotation is combined with size or position animations:
- Size animation changes the wrapper Control's dimensions frame-by-frame
- Position animation moves the Control, affecting rotation calculations
- Either causes the rotation pivot point to shift during the animation
- The rotation tween becomes unstable or fails to play correctly

### Steps to Reproduce

1. Create a `ButteredSausageAnimatorConfig` with:
   - `animate_size = true` OR `animate_position = true`
   - `animate_rotation = true`
   - `rotation_from_degrees = 0.0`
   - `rotation_to_degrees = 360.0`
2. Add this config to a panel's animation chain
3. **Expected:** Panel should slide/move and rotate simultaneously
4. **Actual:** Rotation does not play correctly or appears erratic

### Workaround (Confirmed Working)

**Disable size and position animations when using rotation:**

```gdscript
# Working rotation config
animate_size = false        # Must be false
animate_position = false    # Must be false
animate_rotation = true     # Rotation works perfectly when container is stable
rotation_from_degrees = 0.0
rotation_to_degrees = 360.0
```

With a stable container (no size or position changes), rotation animations work flawlessly. You can still combine rotation with other animation types:
- ✅ Rotation + Fade
- ✅ Rotation + Scale
- ✅ Rotation + Color
- ❌ Rotation + Size (known conflict)
- ❌ Rotation + Position (known conflict)

### Future Plans

We haven't given up on making rotation work with size and position animations. This is on the roadmap for a future update, but it requires deeper investigation into the interaction between container transformations and rotation pivot calculations. If you have expertise in this area and want to contribute a fix, we'd love your help!

### Alternative Approaches

If you specifically need sliding/moving AND rotation effects:
1. Use two separate AnimationStep entries in your chain:
   - Step 1: Size or position animation (slide/move in/out)
   - Step 2: Rotation animation with `animate_size = false` and `animate_position = false`
2. Consider combining rotation with scale + fade for dynamic visual effects

---

**Related Files:**
- `addons/ButteredSausage/ui/animator.gd` - Animation logic
- `addons/ButteredSausage/config/scripts/animator_config.gd` - Configuration structure
- `addons/ButteredSausage/config/resource/animation/simple_rotate.tres` - Example rotation config

**Discussion:** [GitHub Issue #2](https://github.com/standstilldigitalmedia/buttered-sausage/issues/2)
