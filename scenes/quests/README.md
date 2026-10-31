# Village shrine quest

## Play
1. F5 → START GAME. The existing main menu remains the main scene.
2. Visit Echo Shrine beside Abandoned Lane, (880, 680), and Remembrance Shrine
   beside the northern gate/garden approach, (1910, 350). Approach within 120 pixels.
3. Tap the contextual Interact button, or press E. Either collection order works.
   Repeat interactions cannot duplicate a fragment. The tracker counts 0/2 → 2/2.
4. Visit the existing Sacred Flame Shrine in Side Courtyard, (2850, 1210).
   Its interaction sensor is centred on its pedestal, (2850, 1150), radius 140.
5. Interact, then tap Confirm or press E again. Cancel or walk away to decline.
   With fewer than two fragments, restoration is refused. With both, the golden
   light pulses over two seconds, settling at energy 1.8 and texture scale 2.0.
6. Walk to WoodsExit (1728, 160), then Interact. Until restoration this route is
   locked. After restoration it opens the canonical Whispering Woods level.
7. The woods player starts at the existing PlayerSpawn (576, 1408). Interact at
   VillageReturn (576, 1464) to return. Village re-entry is (1728, 280), safely
   south of WoodsExit. Fragment and restoration state are retained.
8. Try pause, settings, resume and main menu. START GAME keeps quest progress
   in the same application session and places the player at village PlayerSpawn.
   Stop the application entirely and run again to start a fresh quest.

## Nodes and responsibilities
- ShrineQuestManager autoload: the single source of truth for this local two-
  fragment quest. The two IDs are permanently offered on restoration, not erased.
  This is session-only state; it does not edit the existing audio settings save.
- fragment_shrine.tscn / shrine.gd: a reusable Area2D proximity detector, small
  solid stone pedestal on physics layer 1, existing tile-atlas artwork and one
  inexpensive PointLight2D. Blue and green instances share resources.
- SacredFlameInteraction: only a sensor/script attached beside the existing
  shrine. It references the original light and fragment; no duplicate gold shrine.
- quest_level.gd: connects context, confirmation, objective UI, spawn markers and
  gated travel. UI sits below the existing pause layer and disappears while paused.
- whispering_woods.tscn in scenes/levels is now the canonical playable forest.
  The old whispering_woods_playable.tscn path is only a compatibility alias; it
  has no separate player, map, controls or quest logic. See FOREST_INTEGRATION.md.
- Input action: interact, physical E. Touch uses the contextual Button's pressed
  signal. No changes to attack, burst or movement bindings.

The standalone HUD's 0/3 Sacred Flame Fragment counter is a separate planned
system; this quest deliberately uses its own LIGHT FRAGMENTS 0/2 tracker.
No enemies, boss, inventory save, or inter-level health persistence is added.
The existing Burst gameplay remains a debug placeholder in Player.gd.

## Validation performed
Godot 4.7.2 automated checks cover both collection orders, duplicate prevention,
zero/one-fragment rejection, explicit confirmation/cancel, restoration final light,
locked/unlocked travel, return-state persistence, woods movement and pause.
Keyboard input and simulated GUI clicks exercise the same interaction handlers.
Collision queries using the player's capsule on a 32-pixel search grid found
reachable approach locations for both new altars, the existing shrine and exit.
Rendered village views were inspected. Android hardware/multitouch testing is
still needed. Desktop rendering reports a local shader-cache permission warning.
