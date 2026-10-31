extends SceneTree
var failures := 0
var deaths := 0
func ck(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void: call_deferred("run")
func frames(n: int = 4) -> void:
	for i in range(n): await physics_frame
func run() -> void:
	change_scene_to_file("res://tests/combat/wanderer_test.tscn")
	await scene_changed
	await frames()
	ck(current_scene.get_script() != null, "test controller loaded")
	var p = current_scene.get_node("Player")
	var e = current_scene.get_node("ShadowWanderer/CharacterBody2D")
	ck(e.health == 5 and e.max_health == 5,"Wanderer starts with five HP")
	ck(p.is_in_group("player") and p.collision_layer == 1, "player group and preserved layer")
	p.set_physics_process(false)
	p.position = Vector2(400,340)
	e.global_position = Vector2(600,340)
	var start = e.global_position.x
	await create_timer(0.25).timeout
	ck(e.global_position.x < start, "enemy pursues existing player")
	e.set_physics_process(false)
	e.global_position = p.global_position + Vector2(48,0)
	e.target = p
	e.state = e.State.ATTACK
	e.windup_left = 0.01
	e._physics_process(0.02)
	ck(p.current_health == 4 and p.is_invulnerable, "enemy damage and invulnerability")
	ck(p.knockback_velocity.x < 0, "knockback away from enemy")
	p.take_damage(1,e.global_position)
	ck(p.current_health == 4, "invulnerability rejects repeat damage")
	await create_timer(1.1).timeout
	ck(not p.is_invulnerable and p.sprite.modulate.a == 1.0, "invulnerability expires and feedback resets")
	p.knockback_velocity = Vector2.ZERO
	e.global_position = p.global_position + Vector2(36,0)
	p.attack_pivot.rotation = 0
	p.facing_direction = Vector2.RIGHT
	await frames()
	p.set_physics_process(true)
	Input.action_press("attack")
	await frames(1)
	Input.action_release("attack")
	await create_timer(0.2).timeout
	ck(e.health == 4, "real attack input damages compatible hurtbox once")
	ck(e.state == e.State.STUNNED, "hit feedback and stun")
	p.set_physics_process(false)
	await create_timer(0.2).timeout
	# A narrow wall between sword and enemy must block damage.
	var wall = current_scene.get_node("Wall")
	wall.position = p.position + Vector2(18,0)
	await frames()
	p.perform_attack()
	await create_timer(0.3).timeout
	ck(e.health == 4, "sword blocked by wall")
	wall.position = Vector2(800,340)
	e.died.connect(func(): deaths += 1)
	e.take_damage(2,p.global_position)
	e.take_damage(2,p.global_position)
	await frames()
	ck(deaths == 1 and not is_instance_valid(e), "enemy death emitted once and removed")
	p.take_damage(5,Vector2.ZERO)
	ck(p.current_health == 0 and not p.is_physics_processing(), "player death stops movement")
	p.perform_attack()
	ck(not p.is_attacking, "dead player cannot attack")
	print("WANDERER INTEGRATION: ",failures," failures")
	quit(failures)
