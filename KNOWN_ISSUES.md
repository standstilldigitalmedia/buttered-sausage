# Known Issues

## Slide Out Animation Cannot Combine with Other Transform Animations

**Severity:** Low
**Component:** `ButteredSausageAnimator` (slide_out animation)
**Status:** Known Limitation

### Description

Slide Out animation cannot be combined with other transform animations (Rotation, Scale, Position) in the same AnimatorConfig. However, Rotation, Scale, and Position can all work together simultaneously.

### Technical Explanation

Slide Out animation changes the wrapper Control's dimensions to create a slide/reveal effect. This is fundamentally different from transform animations (Rotation, Scale, Position) which manipulate nodes in-place without changing container dimensions. The size animation affects the layout system in ways that conflict with transform calculations.

### Working Combinations

✅ **These work perfectly together:**
- Rotation + Scale + Position
- Rotation + Scale
- Rotation + Position
- Scale + Position
- Any transform animation + Fade
- Any transform animation + Color

❌ **Slide Out cannot combine with:**
- Slide Out + Rotation
- Slide Out + Scale
- Slide Out + Position
- Slide Out + any transform animation

✅ **Slide Out works with:**
- Slide Out + Fade
- Slide Out + Color
- Slide Out alone (perfect for slide-out menus)

### Recommended Usage

**Slide Out animation** is designed for slide-out panels, drawers, and menu reveals where the container needs to expand/contract.

**Transform animations** (Rotation, Scale, Position) are designed for in-place effects where the container stays stable.

### Alternative Approaches

If you need both sliding AND transform effects:
1. Use two separate `ButteredSausageAnimationStep` entries in your `entrance_animation_chain`:
   - Step 1: Slide Out animation (slide in/out)
   - Step 2: Transform animations (rotate, scale, position)
2. This creates a sequential effect: slide in, then transform

### Example Configuration

```gdscript
# Working: All three transforms together
animate_slide_out = false
animate_rotation = true
animate_scale = true
animate_position = true

# Working: Size with visual effects
animate_slide_out = true
animate_fade = true
animate_color = true

# Not supported: Size with transforms
animate_slide_out = true
animate_rotation = true  # These will conflict
```

---

**Related Files:**
- `addons/ButteredSausage/ui/panel_animator.gd` - Panel animation logic
- `addons/ButteredSausage/config/scripts/panel_animator_config.gd` - Panel animation configuration