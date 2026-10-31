extends "res://scenes/quests/quest_level.gd"
## Reuses village interaction UI, E input, confirmation handling and safe travel.
@export_enum("forest", "hunter", "keeper", "beacon", "village_house") var area: String = "forest"

func _ready() -> void:
	state = get_node("/root/ShrineQuestManager")
	var level := get_parent()
	player = level.get_node("Player")
	var marker := level.get_node_or_null(state.next_spawn) if not state.next_spawn.is_empty() else null
	if marker == null: marker = level.get_node("PlayerSpawn")
	player.global_position = marker.global_position
	state.next_spawn = ""
	var camera: Camera2D = player.get_node("Camera2D")
	if area == "forest":
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = 2304
		camera.limit_bottom = 1536
	camera.reset_smoothing()
	camera.force_update_scroll()
	_build_ui()
	state.changed.connect(_update_tracker)
	_update_tracker()

func _update_tracker() -> void:
	if area == "village_house":
		tracker.text = "VILLAGE TREASURES %d/3" % state.treasures.size()
	elif area == "beacon":
		tracker.text = "ANCIENT BEACON"
	elif state.forest_unlocked():
		tracker.text = "ANCIENT BEACON ROUTE UNLOCKED"
	elif state.forest_completed.size() == 2:
		tracker.text = "Restore the forest shrine in the eastern clearing."
	else:
		tracker.text = "Explore the two forgotten houses.\nRelic %s  |  Journal %s" % ["✓" if state.forest_completed.has("relic") else "—", "✓" if state.forest_completed.has("journal") else "—"]
	tracker.size.y = 54
