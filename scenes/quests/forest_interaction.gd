extends Area2D
## Same proximity/interaction interface as village shrines, without shrine logic.
@export var shrine_title: String = "Interact"
@export_enum("door", "relic", "journal", "beacon", "village", "treasure") var kind: String = "door"
@export_file("*.tscn") var destination: String = ""
@export var arrival_marker: String = ""
@export var treasure_id: String = ""
var player_in_range: CharacterBody2D
var state: Node

func _ready() -> void:
	state = get_node("/root/ShrineQuestManager")
	add_to_group("quest_shrines")
	body_entered.connect(func(body):
		if body is CharacterBody2D and body.is_in_group("player"): player_in_range = body)
	body_exited.connect(func(body):
		if body == player_in_range: player_in_range = null)
	state.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var visual := get_node_or_null("Icon")
	if visual and kind == "relic": visual.visible = not state.forest_completed.has("relic")
	if visual and kind == "treasure": visual.visible = not state.has_treasure(treasure_id)

func available() -> bool:
	return is_instance_valid(player_in_range) and not get_tree().paused

func interact() -> String:
	if not available(): return ""
	if kind == "treasure":
		return ("Treasure recovered: %s. Saved for the final confrontation." % shrine_title) if state.collect_treasure(treasure_id) else "This treasure has already been recovered."
	if kind == "relic":
		return "Lantern Relic recovered." if state.discover("relic") else "You already recovered the Lantern Relic."
	if kind == "journal":
		var first: bool = state.discover("journal")
		return ("Keeper's Journal discovered.\n" if first else "Keeper's Journal:\n") + "Beyond the northern trees stands the Ancient Beacon. Carry the relic; its light remembers the way."
	if kind == "beacon" and not state.forest_unlocked():
		return "The Beacon route is sealed. Recover the relic, read the journal, then restore the forest shrine."
	state.next_spawn = arrival_marker
	if kind == "village": state.returning_to_village = true
	return "travel:" + destination
