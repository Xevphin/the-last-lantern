# Reusable final-arena defenders

`beacon_defenders.tscn` is the saved formation used by the Ancient Beacon encounter. It instances the existing enemy scenes and textures; no new enemy artwork was generated.

| Wave | Instances | Existing scene |
| --- | --- | --- |
| 1 | WestWatch, EastWatch | `res://scenes/enemies/divesh/ShadowWanderer.tscn` |
| 1 | Vanguard | `res://scenes/enemies/divesh/AshImp.tscn` |
| 2 | WestClaw | `res://scenes/enemies/divesh/ShadowStalker.tscn` |
| 2 | EastClaw | `res://scenes/enemies/divesh/AshImp.tscn` |
| 2 | AltarGuard | `res://scenes/enemies/divesh/MossBrute.tscn` |

All four enemy designs use `res://assets/characters/monsters_realistic_poses.png`. DIVESH retains `res://assets/characters/divesh_poses.png`.

The director in `res://scripts/systems/encounters.gd` owns activation, placement checks, the 1.5-second reinforcement delay, shield state, rewards, persistence and boss unlock. The formation alone is a reusable placement asset, not a complete standalone wave controller. Coordinates are local to the Ancient Beacon map; adapt them when reusing elsewhere.

Each holder has `defense_wave` metadata (0 or 1). Holder names are persistence keys (`beacon_guard:<name>`); keep names stable within a run. Defenders remain defeated after retry/re-entry within the running session. New Game resets them. This is not a disk-save system.

The player's new six-frame walk atlas is `res://assets/characters/keeper_walk_cycle.png` (three columns, two rows, row-major playback). Idle and sword attack retain `keeper_realistic_poses.png`. Runtime sampling and caching live in `scripts/visuals/adventurer_frames.gd`.
