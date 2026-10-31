extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1152,648)
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	for i in range(10): await physics_frame
	var p = current_scene.get_node("Player")
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var strip := Image.create(720,120,false,Image.FORMAT_RGBA8)
	Input.action_press("move_right")
	for sample in range(6):
		await create_timer(0.125).timeout
		await RenderingServer.frame_post_draw
		var screen: Vector2 = p.get_global_transform_with_canvas().origin
		var shot := root.get_texture().get_image()
		shot.convert(Image.FORMAT_RGBA8)
		strip.blit_rect(shot,Rect2i(Vector2i(screen)-Vector2i(60,75),Vector2i(120,120)),Vector2i(sample*120,0))
	strip.save_png("res://tests/progression/reports/walk_motion_strip.png")
	Input.action_release("move_right")
	for actions in [["move_up"],["move_left"],["move_down"],["move_right","move_up"]]:
		for a in actions: Input.action_press(a)
		await create_timer(0.65).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/progression/reports/facing_"+str(actions[0])+".png")
		for a in actions: Input.action_release(a)
		await create_timer(0.25).timeout
	await create_timer(0.4).timeout
	quit()
