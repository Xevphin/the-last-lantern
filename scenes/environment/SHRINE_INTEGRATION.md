# Sacred Flame shrine: visual integration

Scene: `res://scenes/environment/sacred_flame_shrine.tscn`
Village instance: `SacredFlameShrine`, anchored at (2850, 1210), matching the unchanged CourtyardReward marker.
Pedestal: local (0, -60), with one 32 x 24 RectangleShape2D on collision layer 1, mask 0.

## Visual states

The scene starts uncollected. It has no script, Area2D, pickup detection, inventory logic, save logic, or particle effects.

The existing collectible system can change the visual state when appropriate:

```gdscript
var visual_states = shrine.get_node("VisualStates") as AnimationPlayer
visual_states.play("collected")
visual_states.advance(0.0)
```

Use `play("uncollected")` and `advance(0.0)` to restore the golden state. On loading a saved game, the gameplay system should apply the correct state; the shrine does not store collection progress.

The collected animation hides `UncollectedVisuals`, disables `UncollectedVisuals/SacredFlameLight`, and shows `DormantFragment`. Both animations are discrete state changes, not continuous effects. There is no autoplay that could overwrite the gameplay system's choice.

## Light

Four PointLight2D nodes are present: three cool guide lights and one golden shrine light. SacredFlameLight uses warm color #FFBD66, energy 1.2, a 256 x 256 radial GradientTexture2D, texture scale 2.0, additive blending, linear filtering, and disabled shadows. Its world position is (2850, 1134). The golden fragment uses an existing atlas icon and an unshaded CanvasItemMaterial. Its pixel filtering remains nearest-neighbor; only the light texture is smooth.

The user-created NightLighting CanvasModulate is preserved: Color(0.27058825, 0.3019608, 0.4392157, 1). No other golden lights are present. Project settings and existing source PNGs were not changed.

## Neutral guide lights

All three use #A7B8D2, the saved radial light texture at scale 2.0, additive blending, linear filtering, and no shadows. These are light nodes only; no new lantern-post artwork or collisions were added.

| Node under VillageLight | Location | Position | Energy |
| --- | --- | --- | --- |
| StreetLight01 | Abandoned Lane | (813, 615) | 0.35 |
| StreetLight02 | South Entrance | (1728, 1680) | 0.45 |
| StreetLight03 | Northern Gate | (1728, 270) | 0.45 |

The original StreestLight01 was renamed StreetLight01. The user's separate SacredFlameLight was consolidated into SacredFlameShrine/UncollectedVisuals/SacredFlameLight to avoid duplicate golden lighting and ensure that collection disables it. The three neutral lights are unaffected by collection.

## Village environment pass

Four WestLane houses have muted colors, boarded windows, small damaged roof sections, collapsed fence remnants, and weeds. Existing cart and rubble obstacle visuals were replaced with assemblies of existing timber, containers, a wheel-like furniture detail, and stone pieces. These are environmental props, not interactable carts or containers. Gate tower damage is visual. New road scuffs are ground-level details and do not change road tiles or collisions.

## Verified

- Godot 4.7.2 scene load and both visual state transitions.
- Actual uncollected and collected light renders with the Forward Mobile renderer on Windows/D3D12.
- All 38 original collision shapes, building/obstacle transforms, road TileMapLayer data, and four gameplay markers preserved.
- One new pedestal collision (39 total).
- All 18 building approaches, WoodsExit, VillageEncounter and CourtyardReward remain connected to spawn in a road-grid check with 16px collision clearance.

Android frame rate, interaction range, and movement with the team's real player controller still require device/gameplay testing.

