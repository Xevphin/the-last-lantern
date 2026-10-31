# Atmosphere and articulated DIVESH animation

DIVESH now uses eight distinct illustrated pose frames rather than only translating one static image. Walking alternates two leg/arm poses; charge uses crouch and lunge poses; shockwave preparation raises the arms and release uses a ground slam; stun uses a staggered pose. Idle breathing, hurt flash, exposed-core highlight and death dissolution remain. This is limited-frame animation, not a full directional animation set.

The built-in imagegen tool created `assets/characters/divesh_poses.png`, using the existing DIVESH artwork as the identity reference. Prompt: transparent 4-column × 2-row sheet of the same charcoal/purple armored humanoid with golden core and eyes; centered complete figures, consistent scale and baseline; idle, two alternating walk poses, charge crouch, running lunge, raised-arm shockwave preparation, ground slam, stunned stagger; distinct limb articulation; no text, floor, scenery or particles. The user's hooded-character sheet was animation inspiration, not copied artwork. Original DIVESH art is preserved.

Frames are loaded once, sampled to 64×80 with nearest-neighbor filtering and displayed at 2×. No per-frame image processing, extra lights or physics changes were added for the boss. Existing attack timing, damage, health, collision and defeat signals are retained.

Environment changes:

- Existing forest mist now drifts slowly, with a maximum five-unit displacement. Its footprint was reduced to keep drift inside existing thickets, away from paths.
- Restored village shrine light pulses by ±0.07 around 1.8 energy; restored forest shrine by ±0.06 around 1.6. Pulsing yields while restoration tweens run.
- Existing restrained village lantern flicker, golden motes, brighter ambient lighting and soft arena light remain.
- No map scene layouts, buildings, routes, collision objects or main quests were changed. Optional village discoveries were left untouched.

Validation: all eight existing suites passed after these changes, including full automated progression, all-angle melee, enemy combat/death, Burst, keyboard/simulated touch controls, live boss duel, collision routes, Beacon restoration, persistent ending and Main Menu return. The additional atmosphere suite checks mist movement/bounds and glow/flicker limits. Animation tests now assert the distinct artwork frame selected for each boss attack state. Rendered captures are in `tests/progression/reports`.

Still needs manual testing: feel and visual continuity during a human-controlled boss fight, physical Android multitouch and device performance. No new APK was built. Optional exploration remains deferred. No commit, push, merge or music was added. Pre-change snapshot: `.delivery-backup/before-atmosphere.zip`.
