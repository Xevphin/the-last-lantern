# The Last Lantern — audio integration

October 31, 2026 · Godot 4.7.2

All **14 requested files** were found, imported and connected. No supplied audio was edited or converted, no substitute track was used, and no additional music was added.

## Exact music mapping

| Context | Supplied file | Behavior |
| --- | --- | --- |
| Main Menu / Settings | `forest.ogg` | Loops |
| Forgotten Village and its houses | `forest.ogg` | Continues from Menu without restarting; shrine restoration does not interrupt it |
| Whispering Woods and its houses | `cave themeb4.ogg` | Loops; fades from the previous track |
| Ancient Beacon / defenders / DIVESH / restoration | `demon lord.mp3` | One continuous looping track; boss activation does not restart it |
| Game End | `Game Over II ~ v3.wav` | Plays once; the ending remains visible when it finishes |
| Defeat screen | `Dark Loop.mp3` | Loops while defeat is open; Retry restores level music, Main Menu restores forest |

The existing MusicDirector remains the sole music manager. It has one AudioStreamPlayer on the Music bus, compares paths to preserve shared tracks, and cancels stale transitions during rapid navigation. Different tracks fade out for 0.5 seconds and in for 0.5 seconds. Loading is threaded after the old stream is released, so unrelated tracks never play over each other. Large songs are not all preloaded. Music continues through pause.

## Effects

- Village default: `gravel.ogg`.
- Woods default: alternating `leaves01.ogg`, `leaves02.ogg`, `mud02.ogg` for mixed forest floor.
- Ancient Beacon: `stone01.ogg`.
- House interiors: alternating `wood01.ogg`, `wood02.ogg`, `wood03.ogg`.
- Button activation: `Menu Selection Click.wav`.

Surface selection is deliberately level-based, not exact tile/material detection. A future level can set `footstep_surface` metadata to gravel, forest, leaves, mud, stone or wood. No TileMap or terrain geometry changed.

Footsteps observe the existing rig's two foot-contact phases per stride. They use actual post-collision movement, support keyboard and virtual joystick, and stop on idle, pause, attack, knockback and death. This top-down game has no airborne movement state. One footstep player with one voice prevents sound stacking; variants alternate and pitch varies by ±4%. Footsteps use -20 dB gain on SFX.

A persistent click player survives scene changes. Button signals are connected once, so mouse, keyboard and touch activation produce one click. Hovering does not click. Two quiet voices allow quick consecutive activations without unbounded overlap. The click gain is -10 dB. Combat-specific sound files were not supplied and were not invented or substituted.

## Buses and Settings

Existing Master, Music and SFX buses are reused. Music routes to Music; clicks and footsteps route to SFX. Settings now includes Master, Music and SFX sliders plus a Music Mute toggle. Music Mute leaves SFX unmuted.

Defaults for new settings are Master 85%, Music 60%, SFX 80%; existing saved levels are preserved. Music source gain is -12 dB, with -8 dB for the one-shot ending. Changes persist through the existing `user://settings.cfg` without removing unrelated settings sections. AudioSettings centralizes values so scene travel does not reset them.

## Verification

**Result: all 14 regression suites passed.** The expanded audio suite also passed after adding joystick, attack/knockback and rapid-transition coverage. An early fanfare-duration assertion was sensitive to mixer buffering during concurrent tests; it now waits for playback to finish within a bounded allowance and verifies that the track does not restart.

- Full automated audio route: Menu → Village → Woods → forest house → Beacon → DIVESH → restoration context → ending/fanfare completion → Menu.
- Death, looping defeat music, Retry, defeat-to-Menu, pause behavior and same-track continuity.
- Actual imported OGG, MP3 and WAV resources; loop flags; one authoritative player; no missing required audio.
- Keyboard and simulated joystick footsteps, contact timing, variation, stopping, attack and knockback suppression.
- One activation click across scene changes, separate bus volume/mute controls, and persistence through an isolated ConfigFile test (without changing user preferences).
- Existing gameplay regression suites, including the current enemy/boss balance and complete quest-to-ending progression.
- Rendered Settings inspected at 1152×648 and 960×540. A real 2.47-second music-and-click mix was recorded: nonzero output, peak 0.0988 of full scale, zero clipped samples in that sample. This is a signal check, not a listening judgment for every track.

Run `python tests/progression/run_checks.py`. Audio evidence is in `tests/progression/reports/audio_checks.log`, `audio_settings.png`, `audio_settings_small.png` and `audio_mix_preview.wav`. Generated evidence is excluded from exports. The sandbox renderer's existing user shader-cache warning remains unrelated to audio playback.

## Pending and Android

**Missing requested files: none.** Manual listening on speakers/headphones remains necessary for perceived loudness, loop seams, MP3 encoder padding and transition quality over full tracks. No frame-drop or physical Android performance guarantee is claimed from desktop tests.

OGG/MP3 are used in their supplied formats with Godot import resources; the short WAV fanfare/click use standard Godot WAV import. Paths with spaces were successfully loaded. The existing all-resources export preset includes the imported audio. A physical Android build/install/audio test remains pending: Android templates/SDK configuration are still unavailable, and **no APK was built**.

Backup: `.delivery-backup/before-audio-integration.zip`. No pre-existing file is missing. Supplied audio bytes, maps, enemy AI, boss mechanics/balance and animation files match the pre-audio backup. Player changes only attach the footstep listener; defeat changes only expose an audio context marker. Ending text is unchanged. No commit, push or merge was performed.
