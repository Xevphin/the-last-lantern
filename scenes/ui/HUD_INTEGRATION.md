# The Last Lantern HUD

Open `res://tests/hud/hud_preview.tscn` in Godot and press **F6** (Run Current Scene).
Use Damage/Heal, the energy slider, and Fragment −1/+1. Reset restores 5 HP,
100 energy and 0 fragments. The cutout toggle simulates additional screen margins.
Resize the game window to inspect landscape layouts. No main-scene change is needed.

## Scene structure

`GameHUD` is a CanvasLayer: it stays on screen independently of the world camera.
`ScreenRoot` fills the viewport. `PixelLayout` arranges the left vitals panel and
right fragment panel. Containers keep the five TextureRect hearts, caption and
ProgressBar aligned. The fragment TextureRect uses the existing packed tile atlas
at (144, 112), size 16 × 16. Two new 16 × 16 SVG heart assets use square pixel edges.

Nearest texture filtering and whole-number screen scaling (1×–4×) keep hearts
crisp at landscape resolutions. The HUD compensates for canvas stretch so a
source pixel still occupies a whole number of screen pixels. Future changes to
project stretch settings should be retested. Android safe-area bounds map into viewport
coordinates; additional `extra_safe_margins` can be supplied in viewport pixels
(left, top, right, bottom). Real device cutouts still require Android testing.
No new font or external art is needed; captions use Godot's built-in font.

## Display-only integration

Instance `res://scenes/ui/game_hud.tscn` once under your game/UI root. The HUD does
not find players, consume energy, collect fragments or change gameplay values.
All its Controls ignore mouse/touch input so they do not block world controls.
There are no gameplay dependencies, input actions, autoloads or per-frame polling.

Call these methods when the authoritative gameplay values change:

```gdscript
# Example display calls, NOT names of existing teammate signals:
$GameHUD.set_health(3)           # Three filled hearts and two empty hearts.
$GameHUD.set_lantern_energy(42)  # Golden bar, 42/100.
$GameHUD.set_fragments(2)        # Existing fragment artwork, 2/3.
```

Connect Abdul's actual health signal and Divesh's actual energy/fragment signals
in a future integration script after their APIs are agreed. Send an initial
snapshot too, so the HUD does not wait for the first change. No such production
systems were available in this local checkout during HUD development.

Health accepts whole HP and clamps to 0–5. Fragments clamp to 0–3. Energy clamps
to 0–100, supports fractions in the bar, and rounds its text to a whole number.
NaN/infinite energy updates are ignored. Calls made before the HUD enters the
scene tree are retained and displayed when ready. Clamping only protects the
display; it never writes values back into gameplay.

`tests/hud/hud_preview.gd` alone owns mock values and test controls. Do not instance
the preview in production. It creates its controls in `_ready()`, so they appear
when running F6 rather than in the editor's static scene tree.

## Three exercises

1. Press Damage twice. Find the five TextureRects in the HUD scene and compare
   their textures in the running Remote tree: three should be filled.
2. Set energy to 0, 50 and 100. Compare the bar fill and number, then inspect the
   ProgressBar's minimum and maximum properties.
3. Enable simulated cutout margins and resize the preview. Find `PixelLayout`
   in the Remote tree and watch its scale change. Its local scale may be fractional
   to cancel project stretch; the resulting screen scale is a whole number.
