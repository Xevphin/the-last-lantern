extends Area2D

func receive_hit(damage: int, _attacker_pos: Vector2) -> void:
	print("Dummy struck! Damage: ", damage)
	# Visual hit flash
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
