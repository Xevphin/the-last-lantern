extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(label: String) -> void:
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/progression/reports")
	root.get_texture().get_image().save_png("res://tests/progression/reports/" + label + ".png")
func run() -> void:
	root.size = Vector2i(1152,648)
	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await scene_changed
	await capture("menu")
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	await capture("village")
	Input.action_press("move_right")
	await capture("player_walking")
	Input.action_release("move_right")
	var village_player = current_scene.get_node("Player")
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	var index := 0
	for name in ["ShadowWanderer","ShadowStalker","MossBrute","AshImp"]:
		var holder = load("res://scenes/enemies/divesh/%s.tscn" % name).instantiate()
		current_scene.add_child(holder)
		holder.get_node("CharacterBody2D").set_physics_process(false)
		holder.global_position = village_player.global_position + Vector2(-180+index*120,-110)
		index += 1
	await capture("character_lineup")
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	await capture("defenders_arrival")
	current_scene.get_node("Player").global_position = Vector2(1152,1120)
	current_scene.get_node("Player/Camera2D").reset_smoothing()
	await capture("defenders_active")
	preload("res://tests/combat/defender_helpers.gd").cleared_state(self)
	reload_current_scene()
	await scene_changed
	for i in range(8): await physics_frame
	var p = current_scene.get_node("Player")
	p.global_position = Vector2(1152,1040)
	p.get_node("Camera2D").reset_smoothing()
	current_scene.get_node("Encounters").boss.set_physics_process(false)
	await capture("divesh")
	var guardian = current_scene.get_node("Encounters").boss
	for pose in [["charge_crouch", guardian.State.CHARGE_WARNING], ["wave_raise",guardian.State.WAVE_WARNING], ["wave_slam",guardian.State.SHOCKWAVE], ["stunned",guardian.State.STUNNED]]:
		guardian.state = pose[1]
		await capture(pose[0])
	current_scene.get_node("Encounters").boss.take_damage(100)
	current_scene.get_node("VisualStates").play("restored")
	await create_timer(2.1).timeout
	await capture("restored")
	change_scene_to_file("res://scenes/ui/victory.tscn")
	await scene_changed
	await capture("victory")
	print("VISUAL CAPTURES COMPLETE")
	quit()
