extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames() -> void:
	for i in range(10): await physics_frame
func run() -> void:
	for level in ["forgotten_village","whispering_woods","ancient_beacon"]:
		change_scene_to_file("res://scenes/levels/%s.tscn" % level)
		await scene_changed
		await frames()
		var p = current_scene.get_node("Player")
		p.set_physics_process(false)
		for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
		var cam = p.get_node("Camera2D")
		for size in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(2400,1080),Vector2i(960,540)]:
			root.size = size
			await frames()
			var quest = current_scene.get_node("ShrineQuest" if current_scene.has_node("ShrineQuest") else "Quest")
			var health: Rect2 = p.get_node("GameHUD/ScreenRoot/PixelLayout/VitalsPanel").get_global_rect()
			ck(not health.intersects(quest.tracker.get_global_rect()),"quest text clear of health at %s" % size)
			for pos in [Vector2.ZERO,cam.map_size,Vector2(cam.map_size.x,0),Vector2(0,cam.map_size.y)]:
				p.global_position = pos
				cam.reset_smoothing()
				cam.force_update_scroll()
				await frames()
				var corner: Vector2 = root.canvas_transform.affine_inverse()*Vector2.ZERO
				var end: Vector2 = root.canvas_transform.affine_inverse()*root.get_visible_rect().size
				ck(corner.x >= -1 and corner.y >= -1 and end.x <= cam.map_size.x+1 and end.y <= cam.map_size.y+1,"camera inside %s at %s corner %s" % [level,size,pos])
		for guide in current_scene.find_children("GuideLabels","Node2D",true,false): ck(not guide.visible,"blockout labels hidden")
	root.size = Vector2i(1152,648)
	var state = root.get_node("ShrineQuestManager")
	state.start_run()
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	await frames()
	var shrine = current_scene.get_node("SacredFlameInteraction")
	var dark: Color = shrine.atmosphere.color
	state.collect("echo")
	state.collect("memory")
	ck(shrine.atmosphere.color == dark and not state.activated,"both fragments alone do not restore light or unlock woods")
	shrine.player_in_range = current_scene.get_node("Player")
	ck(shrine.interact() == "confirm" and shrine.atmosphere.color == dark,"interaction requires explicit restoration confirmation")
	ck(shrine.confirm_restoration(),"restoration accepted")
	await create_timer(1.0).timeout
	ck(shrine.atmosphere.color != dark and shrine.atmosphere.color != shrine.restored_atmosphere,"gradual lighting still transitioning at one second")
	state.collect_treasure("guardian_sigil")
	ck(shrine.effect.is_running(),"unrelated quest signal preserves light tween")
	await create_timer(1.7).timeout
	ck(shrine.atmosphere.color.is_equal_approx(shrine.restored_atmosphere) and state.activated,"warm restoration reaches target after 2.5 seconds")
	for menu in ["main_menu","setting_menu"]:
		change_scene_to_file("res://scenes/ui/%s.tscn" % menu)
		await scene_changed
		for size in [Vector2i(960,540),Vector2i(2400,1080)]:
			root.size = size
			await frames()
			for control in current_scene.get_children():
				if control is Button or control is HSlider:
					ck(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(control.get_global_rect()),"menu touch target inside viewport: "+str(control.name))
	root.size = Vector2i(1152,648)
	change_scene_to_file("res://scenes/ui/victory.tscn")
	await scene_changed
	await frames()
	var labels = current_scene.find_children("*","Label",true,false)
	ck(labels[0].text.contains("THE LAST LANTERN") and labels[0].text.contains("Game End (Wait for Updates)"),"requested ending text")
	ck(not debug_collisions_hint,"normal gameplay does not draw collision shapes")
	print("SUBMISSION CHECKS failures=",failures)
	quit(failures)
