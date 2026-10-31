# Grounded character art and enemy variety

The cartoon direction was superseded by the user's request for grounded dark-fantasy characters matching DIVESH. Cartoon generations were not integrated. DIVESH's artwork, animations and combat remain unchanged.

## Playable changes

- Player: adult-proportioned teal-hooded lantern keeper in leather/steel armor, carrying both a silver sword and brass lantern. New idle, two walking frames and attack pose.
- Shadow Wanderer: violet spectral knight with cyan eyes, articulated robe/arm poses.
- Shadow Stalker: lean purple clawed beast with amber eyes and walking/attack poses.
- Moss Brute: moss-covered stone golem, 5 HP, speed 62, 0.95-second attack warning, 1.7-second cooldown. Slow, durable, one damage per hit. Its attack warning shows a short ring.
- Ash Imp: rusty-orange horned demon, 2 HP, alternating 145-speed approach for 0.45 seconds and 50-speed hesitation for the rest of its 1.2-second stride. 0.55-second attack warning and one damage per hit.
- Existing village encounters increased from four to seven; forest encounters from five to eight. Three additions in each area, away from arrival points. Defeated enemies retain the existing per-session persistence and energy drops.

Animation sheets are sampled once into cached 80×80 textures, with nearest-neighbor filtering. Frames show distinct limb poses; hit flash and death dissolution remain. This is a limited frame set with horizontal facing, not a complete eight-direction animation library. The existing direction-locked slash and melee query still determine attack direction and reach.

All player/enemy body collision shapes remain unchanged. No map scenes, routes, buildings, house interiors or shrine objectives were modified. Existing lantern flicker, drifting mist, restrained shrine pulses, particles and readable ambient lighting remain. Optional exploration expansion is untouched. No music, commits, pushes or merges were added.

## Art and prompts

Built-in imagegen generated the two project-local assets:

- `assets/characters/keeper_realistic_poses.png`: transparent 2×2 sheet; grounded adult dark-fantasy teal-hooded armored keeper, sword and lantern visible in every frame; idle, opposite walking steps and sword attack; restrained charcoal/teal/steel/gold pixel art, no cartoon/chibi proportions, no scenery/text.
- `assets/characters/monsters_realistic_poses.png`: transparent 4×4 atlas; one row each of spectral Wanderer, purple clawed Stalker, moss stone Brute, rusty-orange Ash Imp; columns idle, two alternating walks, lunging attack; grounded gothic pixel-art style, no cartoon proportions, no scenery/text.

Original assets are preserved. Pre-edit snapshot: `.delivery-backup/before-cartoon-enemies.zip` (the filename records the original direction before the user changed it).

## Tests and limitations

The test runner now includes ten suites. The new variety suite covers Brute/Imp stats, attacks, Imp pacing, Burst damage/stun, death, energy drops, player animation frames, world-clear spawn positions, enemy separation and safe arrival distances. The existing suites cover melee in eight directions, movement/collision routes, touch controls, regular enemies, boss attacks and defeat, atmosphere, restoration, ending persistence, Main Menu and fresh-run reset.

Run `python tests/progression/run_checks.py`. Logs and inspected in-engine character-lineup captures are under `tests/progression/reports`.

Manual testing remains necessary for the increased encounter density and difficulty, animation feel across every facing direction, and physical Android multitouch/performance. Full progression is automated with accelerated travel; it is not a new complete human walking playthrough. No APK was built; the previously documented SDK/template blockers remain. Rendered captures still report the existing sandbox shader-cache warning, without preventing rendering.
