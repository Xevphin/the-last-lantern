extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames(n: int = 16) -> void:
	for i in range(n): await physics_frame
	await process_frame
func release() -> void:
	for a in ["move_left","move_right","move_up","move_down"]: Input.action_release(a)
func run() -> void:
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	await frames()
	var p = current_scene.get_node("Player")
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	var origin: Vector2 = p.position
	var rig = p.visual_motion.walk_rig
	rig.stride = 1.0
	rig.phase = PI/2
	rig.advance(0,130)
	var contact_a: float = (rig.near_leg.polygon[3].x+rig.near_leg.polygon[6].x)/2 - (rig.far_leg.polygon[3].x+rig.far_leg.polygon[6].x)/2
	rig.phase = PI*1.5
	rig.advance(0,130)
	var contact_b: float = (rig.near_leg.polygon[3].x+rig.near_leg.polygon[6].x)/2 - (rig.far_leg.polygon[3].x+rig.far_leg.polygon[6].x)/2
	ck(contact_a > 0 and contact_b < 0,"feet genuinely alternate lead across opposite contacts")
	ck(rig.get_child_count() == 3,"bounded three-piece rig")
	ck(rig.near_leg.material == p.sprite.material,"legs share damage and invulnerability material")
	var torso: PackedVector2Array = rig.get_child(2).polygon.duplicate()
	rig.advance(0.1,65)
	ck(rig.get_child(2).polygon == torso,"head arms equipment and torso never deform")
	var phase_before: float = rig.phase
	rig.advance(0.1,0)
	ck(rig.phase == phase_before,"no stride cycling while stationary")
	var expect_left := false
	for actions in [["move_right"],["move_left"],["move_up"],["move_down"],["move_right","move_up"],["move_left","move_down"],["move_left","move_up"],["move_right","move_down"]]:
		p.position = origin
		for a in actions: Input.action_press(a)
		await frames()
		ck(p.sprite.animation == "walk" and p.animation_speed > 100,"walk direction " + str(actions))
		ck(is_zero_approx(p.sprite.rotation) and p.sprite.scale == Vector2.ONE,"stable torso and size")
		if "move_left" in actions: expect_left = true
		if "move_right" in actions: expect_left = false
		ck(p.sprite.flip_h == expect_left and rig.scale.x == (-1.0 if expect_left else 1.0),"whole character faces movement; vertical travel retains facing")
		release()
		await frames()
		ck(p.sprite.animation == "idle" and p.sprite.position == p.visual_motion.base_position,"grounded idle after stop")
		ck(p.sprite.flip_h == expect_left,"idle retains last facing")
	p.position = origin
	Input.action_press("move_left")
	await frames()
	p.perform_attack()
	await frames(3)
	ck(p.sprite.flip_h and not rig.visible and p.swing_direction.x < 0,"left attack agrees with left-facing rig and hit direction")
	release()
	await create_timer(0.4).timeout
	await frames()
	ck(rig.visible and rig.scale.x == -1 and p.sprite.flip_h,"left attack returns to left-facing idle")
	p.position = origin
	var wall := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(20,200)
	shape.shape = box
	wall.add_child(shape)
	current_scene.add_child(wall)
	wall.position = origin + Vector2(40,0)
	Input.action_press("move_right")
	await frames(35)
	ck(p.animation_speed < 2 and p.sprite.animation == "idle","wall stops feet despite held input")
	release()
	wall.queue_free()
	await frames()
	Input.action_press("move_right")
	await frames()
	p.perform_attack()
	await frames(3)
	ck(p.sprite.animation == "attack","attack overrides held movement")
	ck(not rig.visible and p.sprite.self_modulate.a == 1.0,"attack artwork replaces leg rig")
	await create_timer(0.4).timeout
	await frames()
	ck(p.sprite.animation == "walk","movement resumes after attack")
	ck(rig.visible and p.sprite.self_modulate.a == 0.0,"walking restores rig without doubled sprite")
	p.trigger_burst()
	await frames(3)
	ck(p.sprite.animation == "walk" and p.get_node("LanternBurst").cooldown_left > 0,"burst preserves walk")
	p.take_damage(1,p.position-Vector2(100,0))
	await frames(3)
	ck(p.animation_speed == 0 and p.sprite.animation == "idle","knockback does not cycle feet")
	release()
	await create_timer(0.5).timeout
	await frames()
	ck(p.sprite.animation == "idle","knockback settles into idle")
	print("PLAYER WALK CHECKS failures=",failures)
	quit(failures)
