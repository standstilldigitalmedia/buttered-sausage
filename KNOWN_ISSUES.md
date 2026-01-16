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

---

## Panel Container Does Not Dynamically Reposition When Panels Close

**Severity:** Low
**Component:** `ButteredSausageDisplay` (positioning system)
**Status:** Known Limitation

### Description

When panels are removed (via auto-dismiss or manual close), the panel container maintains its original size and position. For bottom-anchored positions (BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT), remaining panels do not "fall down" to stay at the anchor point - they stay where they were when all panels were visible.

### Example Scenario

1. Set position_preset to BOTTOM_RIGHT
2. Display 5 panels (container grows upward from bottom-right)
3. 4 panels auto-dismiss
4. The remaining panel stays at the "top" of where the container was
5. It does not move down to the bottom-right corner

### Technical Explanation

The display system uses `layout_mode = 0` (unmanaged positioning) for the VBoxContainer to allow precise positioning via the 9-position preset system. With unmanaged layout, Godot does not automatically recalculate the container's size when children are removed. The container size must be manually managed, which would require:

1. Calculating total height of remaining children
2. Setting custom_minimum_size explicitly
3. Forcing layout updates at the right time
4. Handling this across all position presets correctly

This requires architectural changes to the layout system and proper testing across all 9 position presets.

### Workaround

For bottom-anchored layouts where dynamic repositioning is important:
- Use `max_visible_panels = 1` so only one panel is ever shown
- Or use top-anchored positions (TOP_LEFT, TOP_CENTER, TOP_RIGHT) where this behavior is less noticeable

### Planned Fix

This will be addressed in version 1.0.2 with a proper architectural solution for container size management in unmanaged layout mode.

**Related Files:**
- `addons/ButteredSausage/ui/display/display.gd` - Display positioning logic
- `addons/ButteredSausage/config/scripts/display_config.gd` - Position preset configuration
