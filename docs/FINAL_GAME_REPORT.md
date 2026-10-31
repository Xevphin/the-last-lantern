# The Last Lantern — final game report

Date: October 30, 2026. This report supersedes earlier delivery notes where counts, artwork or boss tuning differ.

## Playable build

The Godot project is playable from Main Menu through Forgotten Village, Whispering Woods, Ancient Beacon defenders, DIVESH, final Beacon restoration, the dedicated Game End screen and its Main Menu button.

- Village: seven enemies, two fragments, the existing shrine restoration and optional house discoveries.
- Woods: eight enemies, existing relic/journal discoveries, forest shrine and gated Beacon travel.
- Combat: directional sword hits, enemy windups/attacks/deaths, Lantern Burst, energy, cooldown and pickups. Keyboard and on-screen joystick/sword/Burst controls remain connected.
- Visuals: grounded fantasy keeper with sword and lantern, four existing monster designs, animated DIVESH, restrained lantern/shrine effects, moving mist and light particles.
- Death/retry retains discoveries and defeated enemies within the running session. New Game resets progression. There is no new cross-session save system.

## Final-arena changes

Six additional defenders reuse the same enemies seen in the village and woods. Wave 1 has two Shadow Wanderers and an Ash Imp. Wave 2 has a Shadow Stalker, Ash Imp and Moss Brute. Three fight at a time; the next wave follows after a 1.5-second breather. Inactive guards show a shield, and the HUD identifies the current wave.

DIVESH is visible and shielded until every defender is defeated. His existing art and attack animations remain. Arena health is now 22 instead of 15, and Burst stun is capped at 0.65 seconds instead of the ordinary enemies' two seconds. Charge and shockwave warnings remain readable. Clearing the defenders grants two hearts and 25 energy once per run; existing optional treasure bonuses still apply. Defeating DIVESH unlocks the original final Beacon restoration and ending flow.

This targets normal-to-moderate mobile difficulty through mixed enemies and staged pressure. That difficulty rating still needs human phone playtesting; an automated combat bot is not a difficulty benchmark.

Reusable formation: `assets/encounters/beacon_defenders.tscn`. See `assets/encounters/README.md` for enemy scene paths, wave metadata and persistence behavior. No additional enemy art was generated.

## Player walk

Replaced the two-frame walking loop with six distinct stepping poses, retaining the realistic keeper, sword and lantern. Removed the whole-body walk rocking and bouncing. Playback speed follows movement speed, including partial joystick input. The source atlas is saved as `assets/characters/keeper_walk_cycle.png`; the old assets remain available.

This is a limited side-facing animation set with horizontal mirroring, not a complete four- or eight-direction character atlas. Sword collision direction remains independent of the sprite facing. In-engine walk frames and gameplay captures were visually inspected; perceived smoothness in all directions still deserves a manual playtest.

## Verification actually performed

**All 11 automated suites passed after the final gameplay changes.** Run `python tests/progression/run_checks.py` using `C:\Godot\Godot.exe` (Godot 4.7.2). Logs are saved under `tests/progression/reports`.

| Suite | Coverage |
| --- | --- |
| Beacon defenders | Six placements clear world collision; both live waves reach the player; three active at a time; shield prevents boss bypass; reinforcement delay and pause; unlock, reward, retry and New Game; six walk frames and joystick cadence |
| Enemy variety | Brute/Imp behavior, stats, damage, Burst, death/drop, safe placements and character frames |
| Melee accuracy | Eight directions including all four cardinal directions, close contact, walls, one hit per swing |
| Animation | Character pose/state changes, combat visuals and death effects |
| Atmosphere | Existing restrained environment effects and related scene state |
| Wanderer | Pursuit, windup/attack, knockback, invulnerability, melee, walls and death |
| Burst | Keyboard/touch activation, energy cost/cap, cooldown, damage/stun, pickups, pause and walls |
| Guardian/controls | Keyboard movement, simulated simultaneous joystick/sword touches, pause input release, charge aim/contact, shockwave and stun |
| Live Guardian duel | Running boss defeated using movement/sword/Burst input, without direct damage calls, health edits, frozen boss AI or energy refills; defenders are pre-cleared for this isolated test |
| Routes | Actual collision-shape route reachability to required map objectives and house entrances |
| Full progression | Menu start, gated quests, both village fragments, houses, forest objectives/shrine, both defender waves, DIVESH damage/defeat, Beacon restoration, persistent ending, Main Menu, fresh run and death/retry |

**Full progression was actually tested automatically.** The progression test accelerates travel by repositioning the player and freezes enemies for deterministic quest/sword checks. The live boss duel and live defender approach checks run separately. This was not a fresh, complete human-controlled walking playthrough.

Godot imported the new walk atlas and rendered the menu, walking keeper, enemy lineup, defenders, boss poses, restored Beacon and ending. No new critical gameplay/script errors were reported by the eleven suites. The sandboxed editor/renderer still logs unavailable user-data/editor-settings/shader-cache directories; those environment warnings did not prevent import, gameplay checks or screenshots.

## Remaining manual work and Android

- Human review of combat pacing and difficulty, especially all six defenders followed by DIVESH.
- Walk feel across all directions and at slow joystick speeds.
- Physical Android multitouch, installation, frame rate, battery/heat and small-screen readability.
- Optional extra village discoveries remain untouched. No map expansion or main-quest change was made.

**No Android APK was built.** The Android ARM64 export preset is prepared. The earlier actual export failed because Godot 4.7.2 Android templates, a valid Android SDK/build-tools and a configured Java SDK were unavailable. The expected Android debug template and standard SDK adb path remain absent on the final check. `builds` contains no APK. Install/configure those prerequisites before retrying export and testing on a phone.

## Preservation

The pre-pass snapshot is `.delivery-backup/before-final-defenders.zip`. Compared with its 459 source/asset entries, no pre-existing file is missing, and every file under `scenes/levels` is byte-identical to that snapshot. Existing map layouts, buildings, routes and collision objects were preserved. No music was added. No commit, push or merge was performed; all existing uncommitted work remains in the working tree.
