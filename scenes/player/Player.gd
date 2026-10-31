class_name Player
extends CharacterBody2D

signal health_changed(current_hp: int, max_hp: int)
signal player_died

@export var move_speed: float = 130.0
@export var max_health: int = 5
@export var invulnerability_duration: float = 1.0

var current_health: int
var is_invulnerable: bool = false
var is_attacking: bool = false
var facing_direction: Vector2 = Vector2.DOWN
var knockback_velocity: Vector2 = Vector2.ZERO
var swing_hits: Dictionary = {}
var combat_hint: Label
var swing_active := false
var swing_direction := Vector2.DOWN
var swing_elapsed := 0.0
const SWING_DURATION := 0.14
const MELEE_RADIUS := 34.0
const MELEE_OFFSET := 24.0
var visual_motion: Node
var animation_speed := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_pivot: Node2D = $AttackPivot
@onready var sword_hitbox: CollisionShape2D = $AttackPivot/SwordHitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurt2D
@onready var invuln_timer: Timer = $InvulnerabilityTimer

func _ready() -> void:
	add_to_group("player")
	visual_motion = preload("res://scripts/visuals/actor_motion.gd").new()
	visual_motion.configure(self, sprite, "player")
	add_child(visual_motion)
	var footsteps := preload("res://scripts/systems/player_footsteps.gd").new()
	footsteps.name = "Footsteps"
	add_child(footsteps)
	set_collision_mask_value(3, true) # Enemy bodies; keep world and quest layers.
	attack_pivot.rotation = facing_direction.angle()
	if InputMap.action_get_events("burst").is_empty():
		var burst_key := InputEventKey.new()
		burst_key.physical_keycode = KEY_K
		InputMap.action_add_event("burst", burst_key)
	var lantern = preload("res://scenes/lantern/lantern_system.tscn").instantiate()
	lantern.name = "LanternSystem"
	add_child(lantern)
	var burst = preload("res://scenes/lantern/lantern_burst.tscn").instantiate()
	burst.name = "LanternBurst"
	add_child(burst)
	var hud = preload("res://scenes/ui/game_hud.tscn").instantiate()
	hud.layer = 1 # Keep existing pause/settings menus above the HUD.
	add_child(hud)
	hud.get_node("ScreenRoot/PixelLayout/FragmentPanel").hide() # Existing quest tracker owns progression.
	lantern.energy_changed.connect(func(value, _maximum): hud.set_lantern_energy(value))
	health_changed.connect(func(value, _maximum): hud.set_health(value))
	hud.set_lantern_energy(lantern.energy)
	combat_hint = Label.new()
	combat_hint.position = Vector2(24, 160)
	combat_hint.add_theme_font_size_override("font_size", 14)
	combat_hint.add_theme_color_override("font_color", Color("f5c25b"))
	combat_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	combat_hint.add_theme_constant_override("shadow_offset_x", 2)
	combat_hint.add_theme_constant_override("shadow_offset_y", 2)
	hud.add_child(combat_hint)
	current_health = max_health
	health_changed.emit(current_health, max_health)
	sword_hitbox.disabled = true
	invuln_timer.wait_time = invulnerability_duration
	invuln_timer.one_shot = true
	invuln_timer.timeout.connect(_on_invulnerability_timeout)

func _physics_process(delta: float) -> void:
	combat_hint.position.y = $GameHUD/ScreenRoot/PixelLayout/VitalsPanel.get_global_rect().end.y + 10
	var burst_status := "Ready"
	if $LanternBurst.cooldown_left > 0:
		burst_status = "%.1fs" % $LanternBurst.cooldown_left
	elif $LanternSystem.energy < 25:
		burst_status = "Need energy"
	combat_hint.text = "Move WASD / Stick\nSword Space / Tap\nBurst K / Tap: %s" % burst_status
	queue_redraw()
	if swing_active:
		swing_elapsed += delta
		_query_sword_hits()
	# Handle active knockback decay
	if knockback_velocity.length() > 10.0:
		animation_speed = 0.0
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800.0 * delta)
		move_and_slide()
		return
	# Read direction before attack so a turn + attack in the same tick is reliable.
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO and not is_attacking:
		facing_direction = input_vector.normalized()
		attack_pivot.rotation = facing_direction.angle()
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()
	if Input.is_action_just_pressed("burst"):
		trigger_burst()

	if input_vector != Vector2.ZERO and not is_attacking:
		facing_direction = input_vector.normalized()
		# Rotates attack arc towards direction of movement
		attack_pivot.rotation = facing_direction.angle()
		velocity = input_vector * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	# Use displacement after collision response, not the requested velocity.
	animation_speed = get_position_delta().length() / delta if not is_attacking else 0.0

func perform_attack() -> void:
	if current_health <= 0 or is_attacking: return
	swing_hits.clear()
	is_attacking = true
	swing_active = true
	swing_elapsed = 0.0
	swing_direction = facing_direction.normalized()
	attack_pivot.rotation = swing_direction.angle()
	# Query existing overlaps immediately, then again on every active physics tick.
	_query_sword_hits()
	await get_tree().create_timer(SWING_DURATION, false).timeout
	swing_active = false
	queue_redraw()
	await get_tree().create_timer(0.15, false).timeout
	is_attacking = false

func _query_sword_hits() -> void:
	if not swing_active or current_health <= 0: return
	var shape := CircleShape2D.new()
	shape.radius = MELEE_RADIUS
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, global_position + swing_direction * MELEE_OFFSET)
	query.collision_mask = 8 # Dedicated enemy hurtboxes, separate from world/player.
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in get_world_2d().direct_space_state.intersect_shape(query, 64):
		_hit_sword_area(result.collider)

func _hit_sword_area(area: Area2D) -> void:
	if not swing_active or current_health <= 0 or not area.is_in_group("enemy_hurtbox"): return
	var target: Node = area if area.has_method("receive_hit") else area.get_parent()
	if not is_instance_valid(target) or not target.has_method("receive_hit"): return
	if swing_hits.has(target.get_instance_id()): return
	var offset := area.global_position - global_position
	# Tiny close-contact allowance; otherwise only the forward half of the swing.
	if offset.length() > 20 and offset.normalized().dot(swing_direction) < 0.08: return
	var ray := PhysicsRayQueryParameters2D.create(global_position, area.global_position, 1, [get_rid()])
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return
	swing_hits[target.get_instance_id()] = true
	target.receive_hit(1, global_position)

func take_damage(amount: int, source_position: Vector2) -> void:
	if amount <= 0 or is_invulnerable or current_health <= 0:
		return

	visual_motion.flash()
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	# Knockback calculation away from the hit source
	var push_direction = (global_position - source_position).normalized()
	knockback_velocity = push_direction * 180.0

	if current_health == 0:
		die()
		return

	start_invulnerability()

func start_invulnerability() -> void:
	is_invulnerable = true
	invuln_timer.start()
	
	# Flicker visual effect during i-frames
	var loop_count = int(invulnerability_duration / 0.1)
	var tween = create_tween().set_loops(loop_count)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)

func _on_invulnerability_timeout() -> void:
	is_invulnerable = false
	sprite.modulate.a = 1.0

func die() -> void:
	set_physics_process(false)
	swing_active = false
	is_attacking = false
	visual_motion.dissolve_copy()
	sprite.hide()
	sword_hitbox.set_deferred("disabled", true)
	player_died.emit()
	await get_tree().create_timer(0.65, false).timeout
	var defeat := preload("res://scripts/ui/defeat.gd").new()
	add_child.call_deferred(defeat)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")

func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	_hit_sword_area(area)

func trigger_burst() -> void:
	$LanternBurst.try_burst()

func heal(amount: int) -> void:
	if current_health <= 0: return
	current_health = mini(max_health, current_health + maxi(0, amount))
	health_changed.emit(current_health, max_health)

func _draw() -> void:
	if not swing_active: return
	# World-space visual matches the query, regardless of any parent scaling.
	draw_set_transform_matrix(global_transform.affine_inverse())
	var progress := clampf(swing_elapsed / SWING_DURATION, 0, 1)
	var angle := swing_direction.angle()
	var tip := angle - 0.95 + progress * 1.9
	var center := global_position + swing_direction * 8
	draw_arc(center, 47, angle - 0.95, angle + 0.95, 20, Color(1, 0.77, 0.3, 0.25), 10)
	draw_arc(center, 47, tip - 0.65, tip, 12, Color(1, 0.94, 0.72), 5)
	draw_line(center + Vector2.from_angle(tip)*22, center + Vector2.from_angle(tip)*50, Color.WHITE, 3)
	draw_set_transform_matrix(Transform2D.IDENTITY)
