extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func run() -> void:
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	var boss = current_scene.get_node("Encounters").boss
	var p = current_scene.get_node("Player")
	p.set_physics_process(false)
	boss.set_physics_process(false)
	var motion = boss.visual_motion
	motion.set_process(false)
	var transforms: Array[Transform2D] = []
	var poses: Array[int] = []
	for state in [boss.State.IDLE, boss.State.CHASE, boss.State.CHARGE_WARNING, boss.State.CHARGE, boss.State.WAVE_WARNING, boss.State.SHOCKWAVE, boss.State.STUNNED]:
		boss.state = state
		motion._process(0.21)
		transforms.append(boss.sprite.transform)
		poses.append(motion.pose_index)
	ck(poses[2] == 3 and poses[4] == 5 and poses[5] == 6 and poses[6] == 7, "distinct articulated boss artwork follows attack states")
	ck(motion.pose_frames.size() == 8, "eight pose frames loaded")
	ck(transforms[0] != transforms[1], "boss idle and moving poses differ")
	ck(transforms[2] != transforms[3], "charge wind-up and release poses differ")
	ck(transforms[4] != transforms[5], "shockwave preparation and impact poses differ")
	ck(motion.material.get_shader_parameter("exposed") > 0.5, "stunned core highlight")
	motion.flash()
	motion._process(0.01)
	ck(motion.material.get_shader_parameter("hit_flash") > 0.8, "hurt flash shader")
	ck(boss.get_node("CollisionShape2D").shape.size == Vector2(64,64), "boss collision preserved")
	ck(p.get_node("CollisionShape2D").shape.radius == 19 and p.get_node("CollisionShape2D").shape.height == 46, "player collision preserved")
	ck(boss.sprite.texture.get_size() == Vector2(64,80) and boss.sprite.scale == Vector2(2,2), "boss pixel grid and integer scaling")
	var before: int = current_scene.get_child_count()
	motion.dissolve_copy()
	ck(current_scene.get_child_count() == before + 1, "visible death echo created")
	await create_timer(0.8).timeout
	ck(current_scene.get_child_count() == before, "death echo cleans itself up")
	print("ANIMATION CHECKS failures=", failures)
	quit(failures)
