# Cursed forest props

Created with the built-in image-generation tool for Forgotten Village. No CLI/API fallback was used.

The production file `cursed_forest_props.png` is a 128 x 128 transparent atlas, aligned to a 16px grid. Generated source sprites were trimmed to their alpha bounds and resized with nearest-neighbor sampling. No existing source art was overwritten.

Regions (x, y, width, height):
- Dead tree A: 0, 0, 64, 80
- Dead tree B: 64, 0, 64, 80
- Stump: 0, 96, 32, 32
- Fallen log: 64, 96, 64, 32

## Generation prompt

Create ONE production game sprite sheet PNG, transparent background, square canvas. A sparse 2 by 2 grid of FOUR fully isolated sprites for a 16x16-grid top-down medieval pixel art RPG. Each quadrant contains exactly one complete sprite with generous transparent padding, never crossing quadrant borders: upper left a twisted dead oak tree with gnarled bare branches, upper right a different bent dead tree, lower left a mossy cut tree stump, lower right a horizontal fallen rotten log. Entire silhouettes including branches and roots within each quadrant. No labels, no text, no grid lines, no ground or scenery, no drop shadows outside sprites. Orthographic three-quarter top-down RPG view, coarse deliberate pixel clusters like a sprite drawn at 32x48 pixels then enlarged with nearest neighbor. Limited palette of 8-12 muted dark brown, charcoal, faded olive and gray colors. Hard pixel edges, no gradients, no antialiasing, no glow, no smooth illustration, no realistic texture. Tree sprites tall, stump short, log wide. Darkness must not obscure readable silhouettes. This is a clean atlas of assets, not an illustration.

## Integration

Existing buildings, collision shapes, original road footprint, and gameplay markers are preserved. Main roads and building approach paths now share `VillageArtwork/GroundTiles`. Junction edges were retiled and thresholds extended to remove grass seams. The former separate approach layer was consolidated to avoid selected-layer dimming in the tile editor. Grass shade, bare soil, and moss are separate TileMapLayers. New forest clusters and fallen props are decorative and have no added physics, navigation, scripts, particles, or lights. The existing eight solid trees keep their original collision shapes and positions.

The road check uses a 16px clearance around collision rectangles and verifies that all 18 approach points are reachable from PlayerSpawn. This is a geometric check, not a test with the eventual player controller. Android performance and player occlusion still require in-game testing.

