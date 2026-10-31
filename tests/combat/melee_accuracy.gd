extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func frames(n: int = 3) -> void:
	for i in range(n): await physics_frame
func run() -> void:
	change_scene_to_file("res://tests/combat/wanderer_test.tscn")
	await scene_changed
	await frames()
	var p = current_scene.get_node("Player")
	var e = current_scene.get_node("ShadowWanderer/CharacterBody2D")
	p.set_physics_process(false)
	e.set_physics_process(false)
	e.max_health = 100
	for i in range(8):
		var direction := Vector2.from_angle(i * TAU / 8)
		for distance in [0.0, 12.0, 36.0, 58.0, 90.0]:
			p.global_position = Vector2(400,340)
			p.facing_direction = direction
			e.global_position = p.global_position + direction * distance
			e.health = 100
			await frames()
			p.perform_attack()
			for repeat in range(4): p._query_sword_hits()
			ck(e.health == (99 if distance <= 58 else 100), "angle %d distance %s hits once / respects range" % [i,distance])
			await create_timer(0.31).timeout
	print("40 angle/range/contact cases checked")
	p.facing_direction = Vector2.RIGHT
	e.global_position = p.global_position - Vector2(40,0)
	e.health = 100
	await frames()
	p.perform_attack()
	ck(e.health == 100, "enemy behind player is not hit")
	await create_timer(0.31).timeout
	e.global_position = p.global_position + Vector2(42,0)
	current_scene.get_node("Wall").position = p.position + Vector2(21,0)
	await frames()
	p.perform_attack()
	ck(e.health == 100, "wall blocks melee query")
	await create_timer(0.31).timeout
	current_scene.get_node("Wall").position = Vector2(800,340)
	e.global_position = p.global_position + Vector2(150,0)
	await frames()
	p.set_physics_process(true)
	p.perform_attack()
	e.global_position = p.global_position + Vector2(50,0)
	await frames(4)
	ck(e.health == 99, "enemy entering active swing is hit")
	ck(e.visual_motion.flash_left > 0 and e.knockback.length() > 0, "hit flash and knockback")
	await create_timer(0.31).timeout
	p.facing_direction = Vector2.DOWN
	e.health = 100
	Input.action_press("move_right")
	Input.action_press("attack")
	# physics_frame fires before node processing; allow a complete input tick.
	await frames(2)
	Input.action_release("attack")
	Input.action_release("move_right")
	await frames(2)
	ck(p.swing_direction == Vector2.RIGHT and e.health == 99, "same-tick turn and attack uses current input")
	Input.action_press("move_up")
	await frames(1)
	Input.action_release("move_up")
	ck(p.swing_direction == Vector2.RIGHT, "active swing keeps its visible direction")
	await create_timer(0.31).timeout
	p.perform_attack()
	await create_timer(0.05).timeout
	paused = true
	await create_timer(0.25,true).timeout
	ck(p.swing_active, "pause freezes active swing")
	paused = false
	await create_timer(0.31).timeout
	print("MELEE ACCURACY failures=", failures)
	quit(failures)
