# Player walk refinement — October 31, 2026

## Diagnosis

Inspection covered Player.gd/player.tscn, AnimatedSprite2D, the cached six-frame atlas, actor_motion.gd, speed (130), facing, equipment, and collision dimensions. Whole-body walking rotation was already disabled. The remaining problems were repeated same-leading-leg poses in the atlas; a two-pixel, rounded idle bounce; pre-collision movement driving animation; knockback being treated as walking; two animation owners; and horizontal mirroring swapping the equipment's anatomical hands. Sword and lantern are painted into each frame, not separately attached nodes.

## Implemented

- Animation has one owner in actor_motion.gd. Player movement supplies speed measured from actual post-collision displacement.
- Stationary wall contact stops the feet. Sliding along a wall uses actual sliding speed. Knockback does not play walking; combat physics are unchanged.
- The visible walk now uses a three-piece texture mesh from the original passing pose: far leg, near leg, and fixed upper body. Opposite foot movement changes the leading leg continuously. Foot lift is capped at three texture pixels.
- Cadence follows actual distance traveled: one complete stride per 72 world pixels. No artificial minimum cadence is imposed at slow joystick speeds.
- Idle and walking use the same source texture. Stride amplitude eases in/out over approximately 0.1 seconds; stationary feet settle into a compact stance without changing character proportions.
- Removed player idle bouncing. Walking keeps the torso's position, rotation and scale fixed. The existing attack pose/lean retains priority.
- Restored left/right visual facing after player feedback about moonwalking. The attack sprite and complete walk rig mirror together; idle and vertical movement retain the last horizontal facing. Logical sword hit direction still follows all eight input directions.

Directional limitation: left facing is a mirrored fallback, including the painted equipment. There are no separately drawn left/back/front views. Equipment stays attached and mirrors consistently with the body; anatomical handedness is not preserved by this fallback.

## Artwork and remaining limits

The original six-frame atlas remains preserved. Four generated correction attempts were rejected and none was integrated. Instead, keeper_walk_rig.gd samples the existing passing pose with fixed UVs and animates the leg mesh vertices. Upper-body pixels and equipment are untouched. This corrects the repeated-leading-foot motion without redesigning the character or creating another texture.

This is a restrained lower-leg rig, not a fully articulated hip/knee skeleton or a new directional atlas. Knees and upper legs remain largely fixed under the tunic. The three-quarter view remains a limitation for up/down travel. Human assessment of the movement feel is still needed; physical-phone testing has not been performed.

## Validation

All 12 automated suites passed after the rig integration, including full progression. No new gameplay script errors were reported.

The added player_walk_checks.gd verifies opposite leading feet at opposite phases, a fixed torso mesh, shared damage materials, attack/rig switching, and exercises all eight directions, stop-to-idle, stable torso/scale, equipment orientation, a real temporary collision wall, moving sword attacks, Burst, and knockback. Existing suites retain keyboard and simulated simultaneous virtual-joystick/button coverage, combat, routes and full progression. Tests use the real Player scene and physics; the temporary wall exists only in the test.

Rendered movement is recorded by tests/progression/walk_motion_capture.gd. The output movie is tests/progression/reports/walk-refined.avi; walk_motion_strip.png contains sampled rendered frames for inspection. The earlier implementation was retained as walk-before-rig.avi and walk-before-rig.png. The new rig is recorded in walk-refined.avi. Sampled rendered movement frames and the six-phase rig_contacts.png were inspected. The sandbox renderer's existing user shader-cache warning can still appear.

## Test in Godot

1. Open project.godot in Godot 4.7.2 and press F6 on scenes/levels/forgotten_village.tscn, or F5 and start from Main Menu.
2. Use WASD individually and diagonally. Release input repeatedly and watch the transition into the matching idle pose.
3. Hold movement directly into a house wall: feet should stop. Move diagonally along it: cadence should follow sliding speed.
4. Hold movement and press Space. The attack pose should override walking, then walking should resume. Press K while moving to check Burst.
5. Take an enemy hit: knockback should slide the character without a walking cycle. Check health and invulnerability still behave normally.
6. Drag the virtual joystick slowly and fully, then combine movement with the sword and Burst buttons. Physical-phone feel remains unverified.
7. Compare which boot leads as the cycle progresses. Check the restrained stride feels comfortable; the fixed three-quarter view is a known limitation, not completed directional art.

Automated command: `python tests/progression/run_checks.py`.

Original player, visual scripts and art are backed up in .delivery-backup/before-walk-refinement.zip. Maps, quests, enemies, boss mechanics, menus, collision shapes, camera settings and character size were not edited. No commits or pushes were made.
