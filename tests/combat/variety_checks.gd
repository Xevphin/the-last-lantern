extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames() -> void:
	for i in range(5): await physics_frame
func run() -> void:
	change_scene_to_file("res://tests/combat/wanderer_test.tscn")
	await scene_changed
	await frames()
	current_scene.get_node("ShadowWanderer").queue_free()
	var p = current_scene.get_node("Player")
	p.set_physics_process(false)
	for spec in [["MossBrute",5,2],["AshImp",2,3],["ShadowStalker",2,1]]:
		var holder = load("res://scenes/enemies/divesh/%s.tscn" % spec[0]).instantiate()
		current_scene.add_child(holder)
		var e = holder.get_node("CharacterBody2D")
		e.set_physics_process(false)
		e.global_position = p.global_position + Vector2(48,0)
		await frames()
		ck(e.health == spec[1] and e.art_row == spec[2], spec[0]+" stats and artwork")
		e.target = p
		e.state = e.State.ATTACK
		e.windup_left = 0.01
		p.is_invulnerable = false
		var hp: int = p.current_health
		e._physics_process(0.02)
		ck(p.current_health == hp-(2 if spec[0] == "ShadowStalker" else 1), spec[0]+" attack damage")
		p.knockback_velocity = Vector2.ZERO
		if spec[0] == "AshImp":
			e.stride_time = 0
			e._physics_process(0.01)
			var fast: float = e.move_speed
			e._physics_process(0.6)
			ck(fast > e.move_speed, "imp alternates dart and hesitation")
		elif spec[0] == "ShadowStalker":
			e.global_position = p.global_position + Vector2(0,-150)
			e._physics_process(0.02)
			ck(is_equal_approx(e.move_speed,161.0) and is_equal_approx(e.velocity.length(),161.0),"Stalker pursuit is 40 percent faster than 115")
			e.global_position = p.global_position + Vector2(48,0)
			await frames()
		else: ck(e.attack_windup >= 0.9 and e.move_speed < 90, "brute is slow with a long warning")
		p.get_node("LanternBurst").cooldown_left = 0
		p.trigger_burst()
		await frames()
		ck(e.health == spec[1]-1 and e.state == e.State.STUNNED,spec[0]+" burst damage and stun")
		e.take_damage(10,p.global_position)
		await frames()
		ck(not is_instance_valid(e),spec[0]+" death removes body")
	ck(get_nodes_in_group("energy_pickups").size() == 3,"tested enemies each drop energy")
	ck(p.sprite.sprite_frames.get_frame_count("walk") == 6 and p.sprite.sprite_frames.has_animation("attack"),"player walking and sword pose frames")
	for level in ["forgotten_village","whispering_woods"]:
		change_scene_to_file("res://scenes/levels/%s.tscn" % level)
		await scene_changed
		await frames()
		await frames()
		p = current_scene.get_node("Player")
		var positions: Array[Vector2] = []
		for e in get_nodes_in_group("enemies"):
			e.set_physics_process(false)
			var query := PhysicsShapeQueryParameters2D.new()
			query.shape = e.get_node("CollisionShape2D").shape
			query.transform = e.global_transform
			query.collision_mask = 1
			query.exclude = [p.get_rid()]
			ck(e.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),"enemy spawn clear of world")
			ck(e.global_position.distance_to(p.global_position)>250,"arrival remains safe")
			for position in positions: ck(e.global_position.distance_to(position)>100,"enemy spawns separated")
			positions.append(e.global_position)
	print("VARIETY CHECKS failures=",failures)
	quit(failures)
