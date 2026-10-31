extends SceneTree
## Integration run: uses actual scenes, proximity sensors, UI actions and combat.
## Travel between objectives is accelerated by repositioning, not a human playthrough.
var failures := 0
var state: Node
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func frames(count: int = 6) -> void:
	for i in range(count): await physics_frame
func player() -> Node2D: return current_scene.get_node("Player")
func quest() -> Node:
	return current_scene.get_node("ShrineQuest" if current_scene.has_node("ShrineQuest") else "Quest")
func approach(path: String) -> Node:
	var target := current_scene.get_node(path)
	player().global_position = target.global_position
	player().knockback_velocity = Vector2.ZERO
	await frames()
	return target
func interact(path: String, travel: bool = false) -> void:
	var target := await approach(path)
	ck(target.available(), "proximity: " + path)
	quest()._interact()
	if travel: await scene_changed
	await frames()
func run() -> void:
	state = root.get_node("ShrineQuestManager")
	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await scene_changed
	current_scene._on_start_button_pressed()
	await scene_changed
	await frames()
	ck(get_nodes_in_group("enemies").size() == 7, "village enemy placement")
	# Freeze patrols during quest wiring checks; combat is tested independently.
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	quest().exit_near = true
	quest().target = null
	quest()._interact()
	ck(not quest().changing_scene, "woods gate rejects missing fragments")
	await interact("EchoShrine")
	await interact("RemembranceShrine")
	ck(state.count() == 2, "both village fragments collected")
	await interact("SacredFlameInteraction")
	ck(quest().pending != null, "restoration confirmation shown")
	quest()._confirm()
	ck(state.activated, "village shrine restored")
	# Existing optional house treasures remain usable.
	for door in ["WestLaneNorthEntrance", "MainStreetWestEntrance", "CourtyardSouthEntrance"]:
		await interact(door, true)
		for candidate in get_nodes_in_group("quest_shrines"):
			if candidate.get("kind") == "treasure":
				await interact(str(current_scene.get_path_to(candidate)))
		await interact("Exit", true)
	ck(state.treasures.size() == 3, "all optional treasures retained")
	player().global_position = current_scene.get_node("WoodsExit").global_position
	await frames()
	quest()._interact()
	await scene_changed
	await frames()
	ck(get_nodes_in_group("enemies").size() == 8, "woods enemy variety placed")
	await interact("BeaconExit")
	ck(not quest().changing_scene, "beacon route remains locked")
	await interact("HunterEntrance", true)
	await interact("Discovery")
	await interact("Exit", true)
	await interact("KeeperEntrance", true)
	await interact("Discovery")
	await interact("Exit", true)
	await interact("ForestShrineInteraction")
	quest()._confirm()
	ck(state.forest_unlocked(), "forest shrine restored after discoveries")
	await interact("BeaconExit", true)
	var director := current_scene.get_node("Encounters")
	ck(is_instance_valid(director.boss), "DIVESH spawned")
	var objective := await approach("Encounters/FinalBeacon")
	ck(objective.interact().contains("Defeat"), "beacon refuses restoration while DIVESH lives")
	var boss = director.boss
	ck(not director.engaged and boss.encounter_locked, "DIVESH waits behind defender shield")
	# Clear both groups through actual sword queries, accelerating only movement.
	while not director.engaged:
		for guard in get_nodes_in_group("beacon_defenders"):
			guard.set_physics_process(false)
		for guard in get_nodes_in_group("beacon_defenders"):
			if guard.defense_dormant: continue
			guard.set_physics_process(false)
			guard.global_position = Vector2(1204,1000)
			player().global_position = Vector2(1152,1000)
			player().facing_direction = Vector2.RIGHT
			await frames()
			var attempts := 0
			while is_instance_valid(guard):
				player().global_position = Vector2(1152,1000)
				player().knockback_velocity = Vector2.ZERO
				player().facing_direction = Vector2.RIGHT
				attempts += 1
				if attempts > 20:
					ck(false,"defender sword timeout: %s hp=%s player=%s health=%s" % [guard.global_position,guard.health,player().global_position,player().current_health])
					quit(1)
					return
				player().perform_attack()
				await create_timer(0.32).timeout
		await create_timer(1.6).timeout
	boss.set_physics_process(false)
	ck(director.engaged and boss.max_health == 25 and boss.health == 22, "defenders cleared before boss; guardian sigil reward")
	# Damage comes from the real burst and sword collision system.
	player().global_position = Vector2(1152, 1000)
	boss.global_position = player().global_position + Vector2(52, 0)
	player().facing_direction = Vector2.RIGHT
	player().attack_pivot.rotation = 0
	await frames()
	player().trigger_burst()
	await frames()
	ck(boss.health == 21 and boss.state == boss.State.STUNNED, "burst damages and interrupts DIVESH")
	while is_instance_valid(boss):
		player().perform_attack()
		await create_timer(0.32).timeout
		if is_instance_valid(boss) and boss.health == 21:
			ck(false, "sword reaches boss hurtbox")
			quit(1)
			return
	ck(state.boss_defeated, "DIVESH defeat recorded")
	await interact("Encounters/FinalBeacon")
	await scene_changed
	ck(state.beacon_restored and current_scene.name == "Victory", "restoration animation leads to victory")
	# Ending remains visible even if gameplay accept/attack input is held.
	Input.action_press("ui_accept")
	await create_timer(1.0).timeout
	Input.action_release("ui_accept")
	ck(current_scene.name == "Victory", "ending remains until explicit Main Menu selection")
	var buttons := current_scene.find_children("*", "Button", true, false)
	ck(buttons[0].text == "MAIN MENU", "ending offers Main Menu")
	buttons[0].pressed.emit()
	await scene_changed
	ck(current_scene.scene_file_path.ends_with("main_menu.tscn"), "ending returns only to Main Menu")
	current_scene._on_start_button_pressed()
	await scene_changed
	await frames()
	ck(state.count() == 0 and not state.boss_defeated and state.treasures.is_empty(), "new game resets run")
	# A failed fight always offers a working retry and preserves discoveries.
	state.collect("echo")
	player().take_damage(5, Vector2.ZERO)
	await create_timer(0.75).timeout
	await process_frame
	await process_frame
	ck(paused, "death pauses world")
	var defeat = player().get_children().filter(func(n): return n.get_script() == load("res://scripts/ui/defeat.gd"))[0]
	defeat._leave(true)
	await scene_changed
	await frames()
	ck(not paused and player().current_health == 5 and state.count() == 1, "retry restores health and retains quest progress")
	print("FULL RUN CHECKS failures=", failures)
	quit(failures)
