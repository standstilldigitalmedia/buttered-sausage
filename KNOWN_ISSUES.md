# Known Issues

## Size Animation Cannot Combine with Other Transform Animations

**Severity:** Low
**Component:** `ButteredSausageAnimator` (size animation)
**Status:** Known Limitation

### Description

Size animation cannot be combined with other transform animations (Rotation, Scale, Position) in the same AnimatorConfig. However, Rotation, Scale, and Position can all work together simultaneously.

### Technical Explanation

Size animation changes the wrapper Control's dimensions to create a slide/reveal effect. This is fundamentally different from transform animations (Rotation, Scale, Position) which manipulate nodes in-place without changing container dimensions. The size animation affects the layout system in ways that conflict with transform calculations.

### Working Combinations

✅ **These work perfectly together:**
- Rotation + Scale + Position
- Rotation + Scale
- Rotation + Position
- Scale + Position
- Any transform animation + Fade
- Any transform animation + Color

❌ **Size cannot combine with:**
- Size + Rotation
- Size + Scale
- Size + Position
- Size + any transform animation

✅ **Size works with:**
- Size + Fade
- Size + Color
- Size alone (perfect for slide-out menus)

### Recommended Usage

**Size animation** is designed for slide-out panels, drawers, and menu reveals where the container needs to expand/contract.

**Transform animations** (Rotation, Scale, Position) are designed for in-place effects where the container stays stable.

### Alternative Approaches

If you need both sliding AND transform effects:
1. Use two separate AnimationStep entries in your chain:
   - Step 1: Size animation (slide in/out)
   - Step 2: Transform animations (rotate, scale, position)
2. This creates a sequential effect: slide in, then transform

### Example Configuration

```gdscript
# Working: All three transforms together
animate_size = false
animate_rotation = true
animate_scale = true
animate_position = true

# Working: Size with visual effects
animate_size = true
animate_fade = true
animate_color = true

# Not supported: Size with transforms
animate_size = true
animate_rotation = true  # These will conflict
```

---

**Related Files:**
- `addons/ButteredSausage/ui/animator.gd` - Animation logic
- `addons/ButteredSausage/config/scripts/animator_config.gd` - Configuration structure
