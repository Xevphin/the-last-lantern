extends SceneTree
## Real-time combat bot: no health edits, damage calls, frozen AI or refilled energy.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	preload("res://tests/combat/defender_helpers.gd").cleared_state(self)
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	var p = current_scene.get_node("Player")
	var boss = current_scene.get_node("Encounters").boss
	var seconds := 0.0
	while is_instance_valid(boss) and p.current_health > 0 and seconds < 100:
		var delta := 1.0/60
		seconds += delta
		var direction: Vector2 = p.global_position.direction_to(boss.global_position)
		var distance: float = p.global_position.distance_to(boss.global_position)
		if distance < 175 and p.get_node("LanternBurst").cooldown_left <= 0 and p.get_node("LanternSystem").energy >= 25:
			Input.action_press("burst")
		else:
			Input.action_release("burst")
		var in_charge_lane: bool = absf((p.global_position-boss.global_position).dot(boss.charge_direction.orthogonal())) < 80
		if (boss.state == boss.State.CHARGE_WARNING or boss.state == boss.State.CHARGE) and in_charge_lane:
			Input.action_release("attack")
			direction = boss.charge_direction.orthogonal()
		elif (boss.state == boss.State.WAVE_WARNING and boss.time_left < 0.8) or boss.state == boss.State.SHOCKWAVE:
			Input.action_release("attack")
			# Stay near the wave edge so recovery creates a melee opportunity.
			direction = -direction if distance < boss.wave_radius + 25 else Vector2.ZERO
		elif distance < 60:
			# Face the enemy with a movement tick between sword swings.
			if not p.is_attacking:
				if p.facing_direction.dot(direction) < 0.9:
					Input.action_release("attack")
				else:
					Input.action_press("attack")
					direction = Vector2.ZERO
			else:
				Input.action_release("attack")
				direction = Vector2.ZERO
		else:
			Input.action_release("attack")
		for pair in [["move_right", direction.x], ["move_left", -direction.x], ["move_down", direction.y], ["move_up", -direction.y]]:
			if pair[1] > 0.15: Input.action_press(pair[0], pair[1])
			else: Input.action_release(pair[0])
		await physics_frame
	for action in ["move_right","move_left","move_down","move_up","attack","burst"]: Input.action_release(action)
	print("LIVE DUEL: defeated=", not is_instance_valid(boss), " player_hp=",p.current_health," seconds=",seconds)
	quit(0 if not is_instance_valid(boss) else 1)
