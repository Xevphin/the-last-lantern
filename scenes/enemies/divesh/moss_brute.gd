extends "res://scenes/enemies/divesh/shadow_wanderer.gd"
func _init() -> void:
	art_row = 2
	enemy_title = "Moss Brute"
	move_speed = 62
	max_health = 5
	attack_damage = 1
	attack_windup = 0.95
	attack_cooldown = 1.7
	detection_radius = 260
	lose_target_radius = 360

func _draw() -> void:
	super._draw()
	if state == State.ATTACK:
		draw_arc(Vector2.ZERO, attack_range, 0, TAU, 24, Color(0.9,0.7,0.25,0.7),2)
