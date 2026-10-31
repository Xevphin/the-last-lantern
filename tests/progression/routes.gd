extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for spec in [
		["forgotten_village", Vector2i(4096,2304), ["EchoShrine", "RemembranceShrine", "SacredFlameInteraction", "WoodsExit", "WestLaneNorthEntrance", "MainStreetWestEntrance", "CourtyardSouthEntrance"]],
		["whispering_woods", Vector2i(2304,1536), ["HunterEntrance", "KeeperEntrance", "ForestShrineInteraction", "BeaconExit", "VillageExit"]],
		["ancient_beacon", Vector2i(2304,1536), ["BossSpawn", "FragmentObjective"]]]:
		change_scene_to_file("res://scenes/levels/%s.tscn" % spec[0])
		await scene_changed
		for i in range(6): await physics_frame
		var p = current_scene.get_node("Player")
		p.set_physics_process(false)
		for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
		var grid := AStarGrid2D.new()
		grid.region = Rect2i(Vector2i.ZERO, spec[1] / 16)
		grid.cell_size = Vector2(16,16)
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		grid.update()
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = p.get_node("CollisionShape2D").shape
		query.collision_mask = 1
		query.exclude = [p.get_rid()]
		for y in grid.region.size.y:
			for x in grid.region.size.x:
				query.transform = Transform2D(0, Vector2(x,y)*16 + Vector2(0,4))
				if not p.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
					grid.set_point_solid(Vector2i(x,y))
		var start := Vector2i((p.global_position / 16).round())
		for target_name in spec[2]:
			var target: Vector2 = current_scene.get_node(target_name).global_position
			var reachable := false
			for offset in [Vector2.ZERO,Vector2(0,48),Vector2(0,-48),Vector2(48,0),Vector2(-48,0),Vector2(0,80)]:
				var end := Vector2i(((target + offset)/16).round())
				if grid.is_in_boundsv(end) and not grid.is_point_solid(end) and not grid.get_id_path(start,end).is_empty():
					reachable = true
					break
			print("PASS " if reachable else "FAIL ", spec[0], " walkable route to ", target_name)
			if not reachable: failures += 1
	print("ROUTE CHECKS failures=", failures)
	quit(failures)
