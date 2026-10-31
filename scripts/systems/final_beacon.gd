extends Area2D
var shrine_title := "Restore the Ancient Beacon"
var player_in_range: Node2D
var restoring := false
@onready var state: Node = get_node("/root/ShrineQuestManager")

func _ready() -> void:
	add_to_group("quest_shrines")
	body_entered.connect(func(body):
		if body.is_in_group("player"): player_in_range = body)
	body_exited.connect(func(body):
		if body == player_in_range: player_in_range = null)

func available() -> bool:
	return is_instance_valid(player_in_range) and player_in_range.current_health > 0 and not restoring

func interact() -> String:
	if not available(): return ""
	if not state.boss_defeated: return "DIVESH guards the last flame. Defeat him to restore the Beacon."
	restoring = true
	_restore.call_deferred()
	return "The last flame returns to the Ancient Beacon..."

func _restore() -> void:
	var visuals: AnimationPlayer = get_parent().get_parent().get_node("VisualStates")
	visuals.play("restored")
	await visuals.animation_finished
	state.beacon_restored = true
	state.changed.emit()
	get_tree().change_scene_to_file("res://scenes/ui/victory.tscn")
