extends "res://scenes/enemies/divesh/shadow_wanderer.gd"
var stride_time := 0.0
func _init() -> void:
	art_row = 3
	enemy_title = "Ash Imp"
	max_health = 2
	attack_damage = 1
	attack_windup = 0.55
	attack_cooldown = 1.4
	detection_radius = 260
	lose_target_radius = 360

func _physics_process(delta: float) -> void:
	stride_time = fmod(stride_time + delta, 1.2)
	# A quick approach followed by a readable hesitation; no teleporting.
	move_speed = 145 if stride_time < 0.45 else 50
	super._physics_process(delta)
