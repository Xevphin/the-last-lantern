extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames() -> void:
	for i in range(8): await physics_frame
func run() -> void:
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	await frames()
	var director = current_scene.get_node("Encounters")
	var p = current_scene.get_node("Player")
	var boss = director.boss
	ck(get_nodes_in_group("beacon_defenders").size() == 6,"six existing enemy assets defend the arena")
	ck(not director.engaged and not boss.is_physics_processing(),"safe arrival, boss dormant")
	for guard in get_nodes_in_group("beacon_defenders"):
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = guard.get_node("CollisionShape2D").shape
		query.transform = guard.global_transform
		query.collision_mask = 1
		query.exclude = [p.get_rid()]
		ck(guard.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"guard placement clears world collision")
		ck(guard.defense_dormant and not guard.is_physics_processing(),"guard waits for challenge")
	boss.take_damage(100,p.global_position)
	boss.stun(5)
	ck(boss.health == 25 and boss.max_health == 25 and boss.state != boss.State.STUNNED,"25 HP boss shield rejects damage")
	p.global_position = Vector2(1152,1170)
	p.is_invulnerable = true # Keep the stationary path probe alive; attacks are tested separately.
	await frames()
	var active = get_nodes_in_group("beacon_defenders").filter(func(e): return not e.defense_dormant)
	ck(active.size() == 3 and not director.engaged,"only first group joins")
	await create_timer(8.0).timeout
	for guard in active:
		ck(guard.global_position.distance_to(p.global_position) < 120,"first-wave defender reaches player: " + str(guard.get_parent().name))
	for guard in active:
		guard.set_physics_process(false)
		ck(guard.target == p,"defenders pursue challenger")
		guard.take_damage(100,p.global_position)
	await frames()
	ck(not director.engaged,"first group cannot unlock boss")
	paused = true
	var wait_left: float = director.intermission
	await create_timer(0.2,true).timeout
	ck(director.intermission == wait_left,"pause freezes reinforcement delay")
	paused = false
	await create_timer(1.6).timeout
	active = get_nodes_in_group("beacon_defenders").filter(func(e): return not e.defense_dormant)
	ck(active.size() == 3 and director.defense_wave == 1,"second group reinforces")
	await create_timer(12.0).timeout
	for guard in active:
		ck(guard.global_position.distance_to(p.global_position) < 120,"reinforcement reaches player: " + str(guard.get_parent().name))
	for guard in active:
		guard.set_physics_process(false)
		guard.take_damage(100,p.global_position)
	p.current_health = 2
	await create_timer(1.6).timeout
	ck(director.engaged and not boss.encounter_locked,"all six cleared unlocks DIVESH")
	ck(p.current_health == 4,"two-heart breather before boss")
	boss.stun(2)
	ck(boss.time_left <= 0.65,"boss stun capped for moderate difficulty")
	var state = root.get_node("ShrineQuestManager")
	ck(state.defeated_enemies.has("beacon_defense_reward"),"one-time reward recorded")
	reload_current_scene()
	await scene_changed
	await frames()
	ck(get_nodes_in_group("beacon_defenders").is_empty(),"retry preserves defeated defenders")
	state.start_run()
	reload_current_scene()
	await scene_changed
	await frames()
	ck(get_nodes_in_group("beacon_defenders").size()==6,"new game resets formation")
	p = current_scene.get_node("Player")
	p.set_physics_process(false)
	p.velocity = Vector2(130,0)
	p.animation_speed = 130
	p.visual_motion._process(0.1)
	ck(p.sprite.sprite_frames.get_frame_count("walk")==6,"six walk poses")
	ck(is_zero_approx(p.sprite.rotation) and p.sprite.position == p.visual_motion.base_position,"no whole-body waddle or bounce")
	p.velocity = Vector2(65,0)
	p.animation_speed = 65
	p.visual_motion._process(0.1)
	ck(is_equal_approx(p.sprite.speed_scale,0.5),"walk cadence follows analog movement")
	print("BEACON DEFENSE CHECKS failures=",failures)
	quit(failures)
