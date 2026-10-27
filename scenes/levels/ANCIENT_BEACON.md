# Ancient Beacon

Level: `res://scenes/levels/ancient_beacon.tscn`
Desktop preview: `res://tests/ancient_beacon/beacon_preview.tscn`

## Layout

A 2304 × 1536 ruined temple, assembled from existing stone artwork on a 16px source grid. An octagonal enclosure, high masonry faces, broken columns and four weathered memorial figures borrow the reference image's enclosing architecture and central ritual focus. The art remains flat top-down pixel art. No reference-image textures or new downloads are used.

The approximately 1280 × 800 arena occupies Rect2(512, 320, 1280, 800). Pillars and rubble mostly frame its edges. The southern gateway and approach are 256px wide. The altar is north of the arena centre; its decorative steps are walkable and only the pedestal is solid. The core is visually elevated above the pedestal.

| Marker | World position | Purpose |
| --- | --- | --- |
| PlayerSpawn | 1152, 1440 | Arrival from Whispering Woods |
| BossSpawn | 1152, 896 | Clear boss staging area south of the altar |
| FragmentObjective | 1152, 704 | Reachable standing/interaction point for the final objective |
| BeaconCore | 1152, 496 | Visual/effect anchor above the altar; not a player spawn or collection trigger |

Markers do not spawn enemies or collect fragments. The boss system decides when the fragment appears, when restoration is permitted, and when completion is saved. There is no boss logic, player integration, Area2D pickup, scene transition, save logic or enemy navigation map in this level.

## Scene structure

- **AncientBeacon / Node2D:** holds the level and its map-size and arena metadata.
- **Ground / AncientStoneFloor / TileMapLayer:** paints stone flooring from House_tileset.png. Slab joints, cracks, processional inlays and walkable altar steps are visual details. Tile physics and navigation are disabled.
- **TempleArchitecture:** assembled walls, stone caps and a northern apse. Wall rectangles follow each segment, including diagonal sections.
- **RuinsAndPillars:** solid column bases, collapsed masonry and monuments. These use StaticBody2D and small rectangular CollisionShape2D footprints. Tall artwork extends above the base without blocking the whole silhouette.
- **Boundaries:** closes the outer map and sides of the southern approach.
- **BeaconAltar:** the pedestal, core crystal and a single PointLight2D. Its smooth radial light uses no shadows, particles or animation loop.
- **CorruptedVisuals / RestoredVisuals:** decorative fissures and ceremonial seals. They have no collisions. Their opacity changes during restoration.
- **Atmosphere / CanvasModulate:** supplies the initial dark blue/purple tone, then a warmer and brighter tint.
- **VisualStates / AnimationPlayer:** changes visual properties only. No collision shapes, markers or gameplay state are animated.

Solid scenery uses collision layer 1 and mask 0, matching Forgotten Village and Whispering Woods. The test character is on layer 2 and checks layer 1. A production player/enemy body must also include layer 1 in its collision mask. Actual boss radius, abilities and movement need testing by the boss developer.

The test character is drawn above scenery for visibility. It does not validate production player depth sorting. Integration should arrange the player and relevant architecture under a shared Y-sorted parent, using foot-level origins.

## Restoration integration

The scene's saved properties start corrupted. There is no autoplay, so nothing automatically overwrites a state loaded by the gameplay team.

The `restored` animation takes two seconds. The crystal turns gold first while the room stays dark for the first 0.35 seconds. Purple fissures begin fading after 0.2 seconds; golden seals begin appearing after 0.4 seconds. The crystal and light briefly peak at 0.95 seconds, then settle as the temple finishes warming. The ruined architecture and collision layout stay in place.

### Animation tracks

A track controls one node property. Its keyframes store values at particular times; Godot interpolates between them. These seven tracks use continuous, linear interpolation between their keys, with no looping animation or added effects nodes.

| Track | What it controls |
| --- | --- |
| `Atmosphere:color` | Holds the original dark blue-purple tint until 0.35s, then warms the whole temple through an intermediate tint to the original restored colour at 2s. |
| `CorruptedVisuals:modulate` | Changes alpha (opacity) from 1 to 0. Purple lines remain visible briefly, then disappear by 1.8s. Their positions and geometry do not change. |
| `RestoredVisuals:modulate` | Changes alpha from 0 to 1 after a 0.4s delay, revealing the golden seals by 1.65s. |
| `BeaconAltar/CoreLight:color` | Changes the existing light from purple to gold, briefly uses a paler warm tint at 0.95s, then settles to its original restored gold. |
| `BeaconAltar/CoreLight:energy` | Sets light brightness: 0.65 initially, 0.85 at 0.4s, a 1.6 peak at 0.95s, then 1.35 at 1.35s and 1.15 at 2s. |
| `BeaconAltar/CoreCrystal:modulate` | Turns the crystal gold, brightens its colour to pale gold at 0.95s, then returns to its original restored gold at 2s. Its shape and position stay fixed. |
| `BeaconAltar/CoreLight:texture_scale` | Expands the illuminated area: 3.0 initially and at 0.35s, 4.0 at 0.95s, 3.35 at 1.4s, then 3.0 at 2s. This scales the light texture, not the crystal or pedestal. |

The final restored energy remains **1.15** and the light scale returns to **3.0**. The `corrupted` animation now also sets `texture_scale` to **3.0** at time 0, so resetting halfway through a pulse restores the original radius as well as the existing corrupted colours and brightness. All original corrupted values are unchanged. The effect still uses one shadow-free PointLight2D and its existing gradient texture, with no particles, bloom shader, new assets or gameplay script.

Trigger the visual transition only after the boss/objective system has decided restoration should occur:

```gdscript
var visuals: AnimationPlayer = beacon.get_node("VisualStates")
visuals.play("restored")
```

When loading an already restored save, apply the final appearance immediately:

```gdscript
visuals.play("restored")
visuals.seek(2.0, true)
visuals.advance(0.0)
```

To restore the corrupted appearance:

```gdscript
visuals.play("corrupted")
visuals.advance(0.0)
```

These calls do not defeat the boss, grant the fragment or save progress. The source shrine and other levels are not referenced or changed by these animations. The core crystal is a small pixel-aligned Polygon2D symbol so it can take both purple and golden tints accurately. The temple stone artwork comes from existing atlases; the gameplay team can attach their final fragment effect to BeaconCore.

## Test walkthrough

1. Open `tests/ancient_beacon/beacon_preview.tscn` in Godot 4.7.2. Press **F6**; do not set a new main scene.
2. Click the game, then use **WASD / arrows** to enter the temple from the south. Walk past BossSpawn and circle the altar to reach FragmentObjective.
3. Press **G** and watch the crystal awaken, the light expand briefly, and the temple settle into gold over two seconds. Press **C** to return to corruption. Try pressing C about one second after G: the light radius should reset immediately. These are preview controls, with no persistence.
4. Press **O** for an overview and **M** to hide/show test-only marker labels. **R** returns to spawn. **Esc** or editor **F8** stops the preview.
5. Enable **Debug → Visible Collision Shapes** and approach pillars, rubble, walls and the pedestal from multiple directions. The wide arena floor, cracks, runes and altar steps are passable.

The preview reads physical keys without changing the Input Map or project settings. It is for desktop inspection; Android controls, real-player occlusion, combat balance and device frame rate remain integration tests.

## Three small exercises

1. Select BossSpawn and press F to frame it. Move it 16px inside the arena, then undo. It is a placement marker, not an enemy.
2. Expand a Pillar under RuinsAndPillars and select BaseCollision. Compare the small base rectangle with the tall artwork, then walk around it in the preview with collision visibility enabled.
3. Inspect VisualStates and select `restored`. Scrub to 0s, 0.95s and 2s to compare the seven animated properties. Notice how the light expands at the middle keyframe and returns to its original size. Stop the animation preview and reload the scene if needed to return to its saved corrupted appearance.

## Validation recorded

The restoration pulse was checked separately in Godot 4.7.2: all 120 samples of the two-second timeline stay within the intended light ranges, corruption fades out continuously, and the seals fade in. The 0.95s peak reaches energy 1.6 and texture scale 4.0; the endpoint returns to energy 1.15 and texture scale 3.0 and remains settled. Resetting at 0.95s, 1.0s and after completion restores every original corrupted value, including scale 3.0. Replay, the existing seek(2.0) saved-state shortcut, and the preview's G/C controls pass. All existing nodes, transforms, markers and 38 collision shapes match the pre-pulse scene. Corrupted, peak and settled frames were rendered and inspected with Forward Mobile on Windows.

Checked in Godot 4.7.2: the level and F6 preview load, all solid scenery uses layer 1, and both visual states plus the midpoint of the two-second transition are valid. All 38 collision shapes keep their transforms and sizes across restoration. A 48px diameter physics query reaches PlayerSpawn, BossSpawn and FragmentObjective; the core marker matches the elevated visual anchor. The central combat floor, three entrance lanes covering 208px, and a route around all four sides of the altar are clear. The preview's W movement, R reset, G restoration, C corruption, O overview and M marker labels passed smoke checks. Both visual states were rendered and inspected with Forward Mobile on Windows. Existing project files and other tests were checksum-verified as unchanged. Android frame rate and the real boss/controller remain to be tested on their target systems.
