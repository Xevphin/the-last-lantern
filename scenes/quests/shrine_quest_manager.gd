extends Node
## Session state only: independent of the audio settings file and teammate systems.
signal changed
var collected: Dictionary = {}
var activated: bool = false
var returning_to_village: bool = false
var boss_defeated: bool = false
var beacon_restored: bool = false
var defeated_enemies: Dictionary = {}

func start_run() -> void:
	collected.clear()
	activated = false
	returning_to_village = false
	forest_completed.clear()
	next_spawn = ""
	forest_shrine_activated = false
	treasures.clear()
	defeated_enemies.clear()
	boss_defeated = false
	beacon_restored = false
	changed.emit()

func collect(id: String) -> bool:
	if id not in ["echo", "memory"] or collected.has(id) or activated:
		return false
	collected[id] = true
	changed.emit()
	return true

func count() -> int:
	return collected.size()

func restore() -> bool:
	if activated or count() != 2:
		return false
	# Collected entries stay permanently offered; they cannot be collected again.
	activated = true
	changed.emit()
	return true

# Forest exploration shares this session manager; no second save system.
var forest_completed: Dictionary = {}
var next_spawn: String = ""

func discover(id: String) -> bool:
	if id not in ["relic", "journal"] or forest_completed.has(id):
		return false
	forest_completed[id] = true
	changed.emit()
	return true

func forest_unlocked() -> bool:
	return forest_shrine_activated

var forest_shrine_activated: bool = false
var treasures: Dictionary = {}

func restore_forest() -> bool:
	if forest_shrine_activated or forest_completed.size() != 2:
		return false
	forest_shrine_activated = true
	changed.emit()
	return true

func collect_treasure(id: String) -> bool:
	if id not in ["guardian_sigil", "ember_vial", "keeper_charm"] or treasures.has(id):
		return false
	treasures[id] = true
	changed.emit()
	return true

func has_treasure(id: String) -> bool:
	return treasures.has(id)
