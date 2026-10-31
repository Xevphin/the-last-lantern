extends "res://scenes/enemies/divesh/shadow_wanderer.gd"
## Stalker pursues the living player immediately, regardless of detection distance.
func _init() -> void:
	art_row = 1
	enemy_title = "Shadow Stalker"
	move_speed = 161.0 # 115 * 1.40
	attack_damage = 2
	max_health = 2

func _update_target() -> void:
	if is_in_group("beacon_defenders"):
		super._update_target()
		return
	target = null
	var nearest_distance := 380.0
	for candidate in get_tree().get_nodes_in_group("player"):
		if not candidate is Node2D or candidate.is_queued_for_deletion():
			continue
		if candidate.get("current_health") != null and candidate.get("current_health") <= 0:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			target = candidate
			nearest_distance = distance
