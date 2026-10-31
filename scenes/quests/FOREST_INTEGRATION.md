# Whispering Woods: canonical gameplay integration

## Run
F5 → START GAME → complete the village Sacred Flame quest → interact at WoodsExit.
For isolated forest testing, open scenes/levels/whispering_woods.tscn and press F6.

The original map is canonical. The former quests/whispering_woods_playable.tscn
is a compatibility alias containing one instance of the canonical scene, with no
separate map, player, or logic. Game transitions never load the alias. It was kept
rather than deleting a path that may still be open in the editor.

## Exploration
- Hunter's Lodge: building centre (304,944), door (304,1016).
  Find the Lantern Relic inside. Returning places you at (304,1032).
- Keeper's House: building centre (1120,224), door (1120,296).
  Read the Keeper's Journal inside. Returning places you at (1120,312).
- Each room: player starts (464,480); discovery at (464,280); exit at (464,520).
- Ancient Beacon gate: existing marker (1648,112). Both discoveries and activation of the eastern forest shrine are required.
- Beacon arrival: its existing PlayerSpawn (1152,1440). A contextual return near
  the southern entrance leads back to forest BeaconReturn (1648,192).

Approach doors/items/gates and press E or tap the contextual Interact button.
Both objectives work in either order. The relic disappears after collection;
the journal can be reread but registers completion only once. Progress persists
through interiors, village, forest and Beacon in the same application session.
Restarting the application clears it; no disk save system was introduced.

## Implementation
Forest interactions reuse the village Area2D interface, contextual UI and travel
handler. Forest state extends the existing ShrineQuestManager rather than adding
another autoload. No new input actions or changes to combat/mobile controls.
The original forest tile data, main paths, base lighting remain unchanged. The existing eastern shrine now awakens after
both house discoveries; its warm light brightens briefly on activation. Houses now occupy separate woodland pockets away from both encounter
clearings. Vegetation and thicket collision rectangles were selectively cleared
for these pockets and short side trails. Return points follow the new doors.
The forest camera is constrained to the map boundaries.
The two exteriors are enlarged assemblies of existing village pixel-art tiles,
not bespoke art matching the inspiration images. Interiors reuse wood/furniture
atlases with simple solid wall art and one warm light per room. Relic/journal
icons are temporary existing-atlas symbols, not newly downloaded assets.

Ancient Beacon now includes player, mobile controls, pause/settings and return
interaction. Temple geometry, lighting/restoration animation and boss markers
are untouched. No boss logic was added. Player health still follows the existing
player scene lifecycle (fresh instance on each transition).

## Manual checks
1. Enter each house, find its objective, and exit; confirm the correct return door.
2. Try the Beacon gate with zero and one objective: it must stay locked.
3. Finish both in either order; the tracker directs you to the eastern shrine.
   Tap Interact there and Confirm. Only then does the Beacon route unlock.
4. Enter Beacon and return, then return to village and re-enter the forest.
   Completed objectives must remain completed; relic must not respawn.
5. Test joystick, attack, burst input, pause/resume, paused settings and Main Menu
   inside both rooms and outdoors. Android device/multitouch checks remain manual.
6. Use F5 or canonical F6 for gameplay. The old tests/whispering_woods movement
   harness is preserved but predates the production player now in the map.

Automated Godot validation covers both orders, duplicate prevention, gated travel,
correct return spawns, and state persistence. Capsule-shaped physics queries on
an accessible 16-pixel grid check doors, objectives, exits and return clearance.
Rendered forest/interior views were inspected. A local shader-cache permission
warning may appear in automated desktop rendering without preventing rendering.

## Village treasures and forest polish
Three existing village buildings now have enterable rooms:
- WestLaneNorth: door (770,464), Guardian Sigil; return (770,488).
- MainStreetWest: door (1420,1614), Ember Vial; return (1420,1638).
- CourtyardSouth: door (2980,1594), Keeper Charm; return (2980,1618).

Each treasure can be collected once per running session. The tracker displays
0/3 through 3/3. These are records for future boss integration, NOT implemented
combat buffs. Teammates can query ShrineQuestManager.has_treasure(id), using
guardian_sigil, ember_vial or keeper_charm. Icons reuse temporary atlas symbols.
No inventory screen or disk persistence is added.

Tap the large contextual button near a doorway, item or shrine; E remains an
optional desktop shortcut. Existing Attack, Burst, joystick and Pause are retained.

Forest house paths use existing dirt tiles with irregular edges and grass flecks.
ForestMist creates shared radial-gradient sprites over solid woodland rectangles,
with no particles or per-frame updates. It leaves the walkable routes clear.
Editor collision outlines are editing guides; they are not normal game artwork.
Disable Debug > Visible Collision Shapes when previewing the final appearance.
