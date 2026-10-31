# Combat integration: Phases 1 and 2

Open wanderer_test.tscn and press F6. WASD or joystick moves the existing player.
Space or the existing sword button attacks. Approach the purple placeholder;
its red attack flash is the warning to step away. The grey wall blocks attacks.
Restart test resets the room after either character dies.

The purple square and Godot player icon are temporary artwork, not final sprites.
Press K or the existing flame button to Burst: cost 25 energy, cooldown 2 seconds,
radius 180 pixels, 1 damage and 2 seconds of stun. Defeated Wanderers drop one
energy pickup restoring 15 (maximum 100). Walk over the gold pickup to collect it.
No healing rewards or enemies were added to real levels.

Divesh's Wanderer logic was adapted individually from his Desktop project.
The enemy uses body layer 3 (bit value 4), mask 1. Its hurtbox uses layer 1,
mask 0 and the enemy_hurtbox group, matching the existing sword's area mask.
Player.gd adds the player group and enables enemy body detection in its mask;
the player's body layer and saved scene position are unchanged. receive_hit()
forwards sword damage to the enemy's take_damage(). Enemy attacks pass their
position to the player's existing two-argument damage method.

Player fixes: one movement step during knockback, default sword direction down,
one hit per target per swing, wall ray check, dead-player attack guard, deferred
hitbox disabling on death, and attack timers that stop while the tree is paused.

Run automated checks:
C:/Godot/Godot.exe --headless --path C:/Godot/the-last-lantern --script res://tests/combat/wanderer_checks.gd

Phase 1 checks passed in Godot 4.7.2: pursuit, damage, invulnerability expiry,
knockback direction, real attack action, one-hit sword collision, stun, wall
blocking, one-time enemy death and player death. Existing forest quest tests
passed both house orders. Desktop rendering was inspected; its existing shader
cache permission warning did not prevent rendering. Android device testing is pending.

Final boss name for the later integration: DIVESH. ShadowGuardian can remain the
internal filename. Stalker, boss progression and sprite artwork remain subsequent phases.

Phase 2: Player.gd instances the existing HUD, LanternSystem and LanternBurst.
Both the flame button and K use the existing burst action. K is registered at
runtime if that action has no bindings; project.godot is unchanged. The HUD
shows actual health and energy. Its fragment panel is hidden in gameplay because
the existing quest tracker owns progression. Pause/settings stay above the HUD.

Additional checks: run tests/combat/burst_checks.gd with the same headless command.
Passed: keyboard input, simulated touch button, energy cost/cap, cooldown, damage,
stun, one-time death drop and pickup, insufficient energy, HUD updates, paused
cooldown and wall blocking. Original sword checks and both forest quest orders pass.

Energy starts at 100 on each newly instanced player, including scene transitions.
No cross-level vitals persistence or save system was added in this phase. Burst
is a temporary drawn gold ring and flash, with no external artwork or particles.
Android device performance/multitouch remains a manual check.
