extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func frames(n: int = 4) -> void:
	for i in range(n): await physics_frame
func touch(index: int, position: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = down
	root.push_input(event, true)
func run() -> void:
	preload("res://tests/combat/defender_helpers.gd").cleared_state(self)
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	await frames(8)
	var p = current_scene.get_node("Player")
	var boss = current_scene.get_node("Encounters").boss
	p.global_position = Vector2(1152,1100)
	await frames()
	boss.set_physics_process(false)
	var before: Vector2 = p.global_position
	var key := InputEventKey.new()
	key.physical_keycode = KEY_A
	key.pressed = true
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	await frames(10)
	key = InputEventKey.new()
	key.physical_keycode = KEY_A
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	ck(p.global_position.x < before.x - 10, "keyboard movement")
	var joystick = p.get_node("MobileControls/VirtualJoystick")
	var origin: Vector2 = joystick.get_global_transform_with_canvas() * joystick.center
	touch(0, origin, true)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = origin + Vector2(70,0)
	root.push_input(drag, true)
	before = p.global_position
	await frames(10)
	var button = p.get_node("MobileControls/AttackButton")
	touch(1, button.get_global_transform_with_canvas().origin, true)
	await frames(2)
	ck(p.is_attacking and p.global_position.x > before.x, "simultaneous joystick and sword touch")
	touch(1, button.get_global_transform_with_canvas().origin, false)
	paused = true
	await process_frame
	ck(not Input.is_action_pressed("move_right"), "pause releases held joystick")
	paused = false
	touch(0, origin, false)
	await create_timer(0.4).timeout
	p.global_position = Vector2(1152,1000)
	boss.global_position = Vector2(1052,1000)
	p.is_invulnerable = false
	boss.target = p
	boss.next_is_charge = true
	boss._begin_attack()
	ck(boss.state == boss.State.CHARGE_WARNING and boss.charge_direction.x > 0.9, "charge warns and locks aim")
	p.global_position.y += 80
	ck(boss.charge_direction.y == 0, "charge aim does not track dodge")
	p.global_position.y -= 80
	boss.state = boss.State.CHARGE
	boss.time_left = 0.8
	for i in range(20):
		boss._physics_process(1.0/60)
		await physics_frame
	ck(p.current_health == 2, "charge collision deals three damage once")
	await create_timer(1.1).timeout
	p.heal(3) # Isolate the second attack from the first; each now deals three.
	p.knockback_velocity = Vector2.ZERO
	p.global_position = Vector2(1152,1000)
	boss.global_position = Vector2(1052,1000)
	boss.state = boss.State.SHOCKWAVE
	boss.time_left = 0.1
	boss.wave_hits.clear()
	await frames()
	boss._physics_process(0.01)
	boss._physics_process(0.01)
	ck(p.current_health == 2, "shockwave deals three damage once per wave")
	boss.stun(2)
	ck(boss.state == boss.State.STUNNED and boss.wave_distance == 0, "burst stun cancels shockwave")
	print("GUARDIAN / CONTROLS CHECKS failures=",failures)
	quit(failures)
