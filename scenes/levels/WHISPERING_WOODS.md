# Whispering Woods

Environment scene: `res://scenes/levels/whispering_woods.tscn`
Movement preview: `res://tests/whispering_woods/woods_movement_test.tscn`

## Layout and integration

The map is 2304 × 1536 pixels on a 16px tile grid. Spawn is in the south at (576, 1408). The main dirt path winds north through two clearings to AncientBeaconExit at (1648, 112). Its central corridor is about 160px wide, with a grass apron for movement. A branch at the middle bend runs east to the shrine clearing. It is optional: the northern route stays open regardless of the fragment state.

Markers are placement points, not gameplay triggers:

| Marker | Position | Intended use |
| --- | --- | --- |
| PlayerSpawn | 576, 1408 | Arrival from Forgotten Village |
| VillageReturn | 576, 1464 | Future return transition |
| AncientBeaconExit | 1648, 112 | Future transition to Ancient Beacon |
| Encounter01 | 960, 1088 | First enemy encounter clearing |
| Encounter02 | 1328, 480 | Second enemy encounter clearing |
| FragmentObjective | 1984, 820 | Standing/interaction point south of the shrine pedestal |

The team must connect transitions, real enemies, fragment collection and saved progress. This scene has no production gameplay script, player instance, enemy navigation map or Area2D triggers. Place encounter groups inside the clearings first. Enemy pathfinding across the winding route needs a navigation solution from the gameplay team.

## Nodes and collisions

- **WhisperingWoods / Node2D** is the root and holds the map size metadata.
- **Ground / GrassAndPaths / TileMapLayer** paints grass, road edges and dirt in one grid. Tile collisions are disabled; physics is explicit below.
- **Forest / Node2D** uses Y sorting among its children for tree artwork. Background trees sit inside inaccessible thickets.
- **Boundaries / StaticBody2D** rectangles fill the dark, densely wooded regions outside the walkable grass apron. Adjacent sections are merged to reduce physics objects. These prevent shortcuts through background forest. North and south map edges remain closed until transition triggers are integrated.
- **Obstacles / StaticBody2D** contains reachable trees, logs and stumps. Small rectangular CollisionShape2D nodes cover their bases, allowing movement beneath the visual canopy. They use physics layer 1 and mask 0, matching the existing village scenery. A future player/enemy body must include layer 1 in its mask.
- **SacredFlameShrine** instances the existing reusable scene. Its pedestal collision and two visual states are retained. Only this instance's light energy and range are reduced; the source shrine file is unchanged.
- **NightLighting / CanvasModulate** tints the world cold blue. The shrine has one shadow-free PointLight2D with a smooth radial texture. No particles, animated foliage, shadow casters or additional lights are used.
- **Marker2D** nodes mark integration positions and do not obstruct movement.

The cyan test character is drawn above trees for visibility. Its preview does not validate production player depth sorting. When integrating the real player, put the player and relevant tree bodies under a shared Y-sorted parent with origins at their feet.

## Run the movement test

1. Open the project in Godot 4.7.2 and open `tests/whispering_woods/woods_movement_test.tscn` in the FileSystem dock.
2. Press **F6** (Run Current Scene). Do not use F5 or set a main scene.
3. Click the running game. Move with **WASD** or arrow keys. **R** returns to spawn. **G** toggles the shrine's visual state for preview only. **Esc** closes the test; F8 also stops it from the editor.
4. Follow the path through both clearings to the north exit. Return to the middle bend and take the eastern branch to the shrine. A test HUD confirms when you reach each marker.
5. Enable **Debug → Visible Collision Shapes** and run again to inspect bases, thickets and the pedestal. Check wall sliding and approach the shrine from below.

The preview reads physical keys directly. It does not modify the Input Map, project settings or main scene. It is a desktop movement test, not Android controls or the real player controller. Android frame rate and visibility need a later device test.

## Three small exercises

1. Select **Encounter01** in the Woods scene and press F to frame it. Move it 16px inside the clearing, then undo. Notice that a marker changes no collision or artwork.
2. Select an **Obstacles/ReachableTree** and expand its CollisionShape2D. Compare the small base rectangle with the canopy. In the movement test, approach it from all four sides with collision visibility enabled.
3. Run the test and walk to the shrine. Press G twice. Inspect the reusable shrine's **VisualStates** animations to see how `collected` hides the golden fragment and disables its light.

All artwork is reused from existing Outdoor_tileset, Trees_and_bushes and cursed_forest_props atlases and the existing shrine scene. No assets were downloaded.

## Validation

Validated in Godot 4.7.2. Both scenes load and instantiate. A physics query using a 48px diameter body reaches all six markers from spawn. Three sampled lanes along the main route cover 144px without collision overlap. The movement test responds to W, R resets spawn and G toggles both shrine states. The level uses 47 collision shapes, including the shrine pedestal, and one PointLight2D. A Windows Forward Mobile render was inspected for path and shrine visibility. Existing tracked files and village test files were checked against their original checksums and remained unchanged.
