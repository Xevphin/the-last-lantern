# The Last Lantern — submission report

October 31, 2026 · Godot 4.7.2 · Project: `C:\Godot\the-last-lantern`

## Playable content

Main Menu → Forgotten Village → Whispering Woods → two defender waves → DIVESH → Beacon restoration → **Game End (Wait for Updates)** → Main Menu.

Features include directional sword combat, Lantern Burst with energy/cooldown/pickups, five-heart health and retry, four enemy types, village fragments and Sacred Flame restoration, optional house treasures, forest discoveries and shrine, six final-arena defenders, DIVESH charge/shockwave attacks, character animation, mobile controls, pause and separate Music/SFX settings.

Latest requested combat tuning: Shadow Wanderer has 5 HP; Shadow Stalker moves at 161 pixels/second (40% above 115) and deals 2 damage; DIVESH has 25 base HP and deals 3 damage with both charge and shockwave. Existing optional Guardian Sigil still removes 3 boss HP on engagement. These values supersede earlier balance notes.

## Final polish completed

- **Camera:** fixed the village south-entrance gray strip. The map ends at y=1944, while the formerly unrestricted camera could show outside it. Camera limits now match the village's 3456×1944 footprint and the woods/arena's 2304×1536 footprints. Oversized viewports fit within those bounds. No covering UI panel or changed collision geometry was used.
- **Sacred Flame:** collecting both fragments alone leaves lighting and the Woods gate unchanged. Explicit shrine confirmation starts a 2.5-second eased transition to warmer lighting, with restrained light expansion and settling. Unrelated quest updates cannot interrupt the transition.
- **Atmosphere:** preserved lamp flicker and forest mist; added four faint drifting village mist patches, bounded forest fireflies and arena motes. DIVESH's defeat fades arena accents to gold. Existing Beacon restoration remains the final step.
- **Characters:** retained the four enemy designs, larger DIVESH, attack anticipation, damage feedback and death effects. No AI, damage values or combat mechanics were replaced. The player retains the refined independent-foot walk rig.
- **UI:** fitted Main Menu, Settings and Pause to landscape sizes; kept the navy/gold identity; moved quest text clear of the health panel; narrowed the interaction control to keep room for mobile buttons. Settings now has a full background. The ending displays the exact requested title and message, and waits for Main Menu selection.
- **Debug visibility:** designer blockout labels remain in the project but are hidden in gameplay. Collision debug is off in normal tests and explicitly disabled by the map camera in release builds. No working collision shape or quest marker was removed.

## Music and sound effects

The supplied music is now integrated: forest.ogg for Menu/Village, cave themeb4.ogg for Woods, demon lord.mp3 for Beacon/DIVESH, Game Over II ~ v3.wav once for the ending, and Dark Loop.mp3 for defeat. Shared tracks continue without restart. Footsteps and menu clicks are connected, with Master/Music/SFX settings and Music Mute. See AUDIO_INTEGRATION_REPORT.md for exact mappings, tests and listening/device limitations.

## Controls

| Action | Keyboard | Touch |
| --- | --- | --- |
| Move | WASD | Virtual joystick |
| Sword | Space | Sword button |
| Lantern Burst | K | Flame button |
| Interact/confirm | E | Interaction/confirmation buttons |
| Pause | Escape or pause button | Pause button |

## Verification

**Final result: 14/14 suites passed after the completed polish changes, with no failed automated checks.**

Run `python tests/progression/run_checks.py`. The runner covers **14 automated suites**: audio integration, submission checks, player walking, defender waves, enemy variety, melee accuracy, character animation, atmosphere, Wanderer behavior, Burst, boss/controls, a live boss duel, collision routes, and full progression.

New checks cover camera containment at all four map corners in 960×540, 1152×648, 1280×720 and 2400×1080 windows; quest/health separation; menu target bounds; explicit shrine gating and timed lighting; missing music, fade-out and transition cancellation using a silent in-memory test stream; post-boss golden lighting; ending text and disabled collision drawing.

Rendered captures were inspected for the village camera, enemies/boss poses, shrine before/mid/after restoration, menus, pause, Settings and ending at small and wide landscape sizes. Evidence is under `tests/progression/reports` (excluded from export). Other preview scenes in `tests` are interactive developer tools, not additional automated suites.

Full progression is tested automatically using accelerated travel and controlled combat setup; live defender pursuit and a live boss duel are separate checks. This is **not a fresh complete human playthrough or physical Android test**. The sandbox renderer still reports its existing unavailable user shader-cache folder; rendering succeeds. Automated gameplay errors are treated as failures.

## Known limitations and Android

- Physical-phone multitouch, performance, cutouts, heat/battery use and combat difficulty still need device testing. Desktop landscape tests do not establish mobile performance.
- The keeper uses a three-quarter view mirrored for left/right movement and a restrained lower-leg rig, not a complete directional animation atlas. Vertical movement retains the last horizontal facing.
- Supplied music and effects are integrated; full-track listening and physical-device audio checks remain manual. No optional map expansion or unsupported foliage animation was added.
- **No APK was built.** The ARM64 Android preset is prepared, but Godot 4.7.2 Android templates and the standard Android SDK/adb path are absent. ANDROID_HOME/JAVA_HOME are unset; the earlier actual export also reported invalid SDK/build-tools and Java configuration. Recheck export after installing/configuring those prerequisites.

The source project is playable for evaluation in Godot. Android submission readiness remains blocked by export tooling and device validation; no competition-specific packaging requirements were provided or verified.

## Preservation

Snapshot: `.delivery-backup/before-submission-polish.zip`. No pre-existing source/asset file was deleted. All three level scene files are byte-identical to that snapshot: buildings, routes, interiors, collision geometry and markers were preserved. No commit, push or merge was performed.
