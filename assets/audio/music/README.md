# Supplied music assignments

MusicDirector uses these exact supplied files (preserve spelling and spaces):

| Filename | Playback context |
| --- | --- |
| forest.ogg | Main Menu, Settings, Village and village houses; continues without restart |
| cave themeb4.ogg | Woods and forest houses |
| demon lord.mp3 | Arena arrival, defenders, DIVESH and post-boss restoration; continues without restart |
| Game Over II ~ v3.wav | Game End, once only |
| Dark Loop.mp3 | Defeat screen until Retry or Main Menu |

MusicDirector uses one AudioStreamPlayer on the Music bus. Different tracks fade out for 0.5 seconds and in for 0.5 seconds, with threaded loading between them. Shared paths never restart. Tracks do not overlap. All tracks loop except ending. Missing resources produce silence and a warning with the exact path. Rapid navigation cancels stale transitions.

Settings has Master, Music and SFX sliders plus Music Mute, persisted in user://settings.cfg. Existing saved levels are preserved. Default levels are 85%, 60%, 80%; track gain is -12 dB (-8 dB for the ending). Music continues during pause; footsteps stop.

Footstep and click files are under ../sfx. See docs/AUDIO_INTEGRATION_REPORT.md for mappings, verification and physical-device limitations. No supplied audio was converted or edited, and no additional music was added.
