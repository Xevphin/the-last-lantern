extends CharacterBody2D
const ENERGY_DROP = preload("res://scripts/pickups/energy_drop.gd")
## Boss attack timings are placeholders that can be tuned in the Inspector.
signal health_changed(current: int, maximum: int)
signal died
signal boss_defeated

enum State { IDLE, CHASE, CHARGE_WARNING, CHARGE, WAVE_WARNING, SHOCKWAVE, RECOVERY, STUNNED, DEAD }
@export var max_health: int = 25
@export var move_speed: float = 80.0
@export var charge_speed: float = 480.0
@export var attack_damage: int = 3
@export var charge_warning: float = 0.85
@export var charge_duration: float = 0.8
@export var wave_warning: float = 1.4
@export var wave_radius: float = 180.0
@export var wave_duration: float = 0.65
@export var recovery_duration: float = 1.0
var health: int
var state: State = State.IDLE
var target: Node2D
var time_left: float = 0.0
var next_is_charge: bool = true
var charge_direction: Vector2 = Vector2.RIGHT
var wave_hits: Array[int] = []
var wave_distance: float = 0.0
var flash_left: float = 0.0
var visual_motion: Node
var encounter_locked := false
@onready var sprite: Sprite2D = $Sprite2D
@onready var wave_area: Area2D = $ShockwaveArea
@onready var wave_shape: CollisionShape2D = $ShockwaveArea/CollisionShape2D

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	health = max_health
	# Sample the generated artwork on a deliberate low-resolution pixel grid.
	var image := sprite.texture.get_image()
	image.resize(64, 80, Image.INTERPOLATE_NEAREST)
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(2, 2)
	sprite.position = Vector2(0, -48)
	visual_motion = preload("res://scripts/visuals/actor_motion.gd").new()
	visual_motion.configure(self, sprite, "boss")
	add_child(visual_motion)
	_recover()

func _find_player() -> void:
	target = null
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is Node2D and not candidate.is_queued_for_deletion():
			if candidate.get("current_health") == null or candidate.get("current_health") > 0:
				target = candidate
				return

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_find_player()
	velocity = Vector2.ZERO
	flash_left = maxf(0.0, flash_left - delta)
	time_left = maxf(0.0, time_left - delta)
	if not is_instance_valid(target):
		state = State.IDLE
		wave_distance = 0.0
	elif state == State.STUNNED:
		if time_left <= 0.0:
			_recover()
	else:
		match state:
			State.IDLE, State.CHASE:
				# Approach before a wave so it can actually threaten the player.
				if not next_is_charge and global_position.distance_to(target.global_position) > wave_radius * 0.8:
					state = State.CHASE
					velocity = global_position.direction_to(target.global_position) * move_speed
					move_and_slide()
				else:
					_begin_attack()
			State.CHARGE_WARNING:
				if time_left <= 0.0:
					state = State.CHARGE
					time_left = charge_duration
			State.CHARGE:
				velocity = charge_direction * charge_speed
				move_and_slide()
				for index in get_slide_collision_count():
					var body = get_slide_collision(index).get_collider()
					if is_instance_valid(body) and body.is_in_group("player") and body.has_method("take_damage"):
						body.take_damage(attack_damage, global_position)
				if get_slide_collision_count() > 0 or time_left <= 0.0:
					_recover()
			State.WAVE_WARNING:
				if time_left <= 0.0:
					state = State.SHOCKWAVE
					time_left = wave_duration
					wave_hits.clear()
			State.SHOCKWAVE:
				wave_distance = wave_radius * (1.0 - time_left / wave_duration)
				_damage_wave()
				if time_left <= 0.0:
					_recover()
			State.RECOVERY:
				if time_left <= 0.0:
					state = State.CHASE
	sprite.modulate = Color.WHITE
	if state == State.CHARGE_WARNING or state == State.WAVE_WARNING:
		sprite.modulate = Color(2.0, 0.7, 0.7)
	elif state == State.STUNNED:
		sprite.modulate = Color(2.0, 1.8, 0.6)
	elif flash_left > 0.0:
		sprite.modulate = Color(2.0, 2.0, 2.0)
	queue_redraw()

func _begin_attack() -> void:
	if next_is_charge:
		state = State.CHARGE_WARNING
		# Lock aim now so the player can sidestep the warning.
		charge_direction = global_position.direction_to(target.global_position)
		time_left = charge_warning
	else:
		state = State.WAVE_WARNING
		time_left = wave_warning
	next_is_charge = not next_is_charge

func _recover() -> void:
	state = State.RECOVERY
	time_left = recovery_duration
	velocity = Vector2.ZERO
	wave_distance = 0.0

func _damage_wave() -> void:
	var circle := CircleShape2D.new()
	circle.radius = maxf(1.0, wave_distance)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, global_position)
	query.collision_mask = wave_area.collision_mask
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		var body = hit.collider
		if not body.is_in_group("player") or not body.has_method("take_damage"):
			continue
		var id: int = body.get_instance_id()
		if id in wave_hits:
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position, body.global_position, 1, [get_rid(), body.get_rid()])
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		wave_hits.append(id)
		body.take_damage(attack_damage, global_position)

func stun(duration: float) -> void:
	if encounter_locked or state == State.DEAD or duration <= 0.0:
		return
	duration = minf(duration, 0.65)
	if state == State.STUNNED:
		time_left = maxf(time_left, duration)
	else:
		time_left = duration
	state = State.STUNNED
	velocity = Vector2.ZERO
	wave_distance = 0.0
	queue_redraw()

func take_damage(amount: int, _source_position: Vector2 = Vector2.ZERO) -> void:
	if encounter_locked or state == State.DEAD or amount <= 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	flash_left = 0.1
	visual_motion.flash()
	if health == 0:
		state = State.DEAD
		visual_motion.dissolve_copy()
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		var player := get_tree().get_first_node_in_group("player")
		if is_instance_valid(player) and player.has_method("heal"):
			player.heal(1)
		# Progression can connect this to unlock the final beacon.
		boss_defeated.emit()
		ENERGY_DROP.spawn_from(self)
		died.emit()
		queue_free()
	queue_redraw()

func _draw() -> void:
	if encounter_locked:
		draw_arc(Vector2(0,-45), 75, 0, TAU, 48, Color(0.65,0.55,1,0.65), 3)
	draw_rect(Rect2(-40, -140, 80, 7), Color(0.15, 0.15, 0.2))
	draw_rect(Rect2(-40, -140, 80.0 * health / max_health, 7), Color("f5c25b"))
	if state == State.CHARGE_WARNING:
		var side := charge_direction.orthogonal() * 32
		var end := charge_direction * charge_speed * charge_duration
		draw_colored_polygon(PackedVector2Array([-side, side, end+side, end-side]), Color(1, 0.25, 0.1, 0.16))
		draw_line(Vector2.ZERO, charge_direction * charge_speed * charge_duration, Color(1, 0.25, 0.25, 0.6), 6.0)
	elif state == State.WAVE_WARNING:
		draw_circle(Vector2.ZERO, wave_radius, Color(1, 0.25, 0.1, 0.08))
		draw_arc(Vector2.ZERO, wave_radius, 0, TAU, 64, Color(1, 0.35, 0.35, 0.65), 3.0)
	elif state == State.SHOCKWAVE:
		draw_circle(Vector2.ZERO, wave_distance, Color(0.6, 0.35, 0.85, 0.12))
		draw_arc(Vector2.ZERO, wave_distance, 0, TAU, 64, Color("91c7d9"), 5.0)

func receive_hit(amount: int, source_position: Vector2) -> void:
	take_damage(amount, source_position)
