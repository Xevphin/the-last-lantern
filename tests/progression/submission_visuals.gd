extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(label: String) -> void:
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/progression/reports/"+label+".png")
func run() -> void:
	for size in [Vector2i(960,540),Vector2i(2400,1080)]:
		root.size = size
		for spec in [["main_menu","scenes/ui/main_menu.tscn"],["settings","scenes/ui/setting_menu.tscn"],["village","scenes/levels/forgotten_village.tscn"],["ending","scenes/ui/victory.tscn"]]:
			change_scene_to_file("res://"+spec[1])
			await scene_changed
			await capture("submit_%s_%d" % [spec[0],size.x])
			if spec[0] == "village":
				current_scene._on_pause_button_pressed()
				await capture("submit_pause_%d" % size.x)
				current_scene.get_node("PauseUI/PauseMenu")._on_resume_button_pressed()
	root.size = Vector2i(1152,648)
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var shrine = current_scene.get_node("SacredFlameInteraction")
	var p = current_scene.get_node("Player")
	p.global_position = shrine.global_position + Vector2(0,80)
	p.get_node("Camera2D").reset_smoothing()
	var state = root.get_node("ShrineQuestManager")
	state.collect("echo")
	state.collect("memory")
	await capture("submit_shrine_before")
	shrine.player_in_range = p
	shrine.confirm_restoration()
	await create_timer(1.25).timeout
	await capture("submit_shrine_mid")
	await create_timer(2.5).timeout
	await capture("submit_shrine_after")
	print("SUBMISSION VISUALS COMPLETE")
	quit()
