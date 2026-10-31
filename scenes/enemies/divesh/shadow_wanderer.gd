extends CharacterBody2D
const ENERGY_DROP = preload("res://scripts/pickups/energy_drop.gd")
## Simple top-down enemy. World geometry is collision layer 1.
signal health_changed(current: int, maximum: int)
signal died

enum State { IDLE, CHASE, ATTACK, STUNNED, DEAD }
@export var move_speed: float = 90.0
@export var detection_radius: float = 340.0
@export var lose_target_radius: float = 440.0
@export var attack_damage: int = 1
@export var attack_range: float = 56.0
@export var attack_windup: float = 0.45
@export var attack_cooldown: float = 1.25
@export var max_health: int = 5
@export var art_row: int = 0
@export var enemy_title: String = "Shadow Wanderer"
var health: int
var state: State = State.IDLE
var target: Node2D
var cooldown_left: float = 0.0
var windup_left: float = 0.0
var stun_left: float = 0.0
var knockback: Vector2 = Vector2.ZERO
var visual_motion: Node
var defense_dormant := false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	visual_motion = preload("res://scripts/visuals/actor_motion.gd").new()
	visual_motion.configure(self, sprite, "enemy")
	add_child(visual_motion)
	if defense_dormant: sprite.modulate = Color(0.65,0.65,0.85)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if defense_dormant or state == State.DEAD:
		return
	cooldown_left = maxf(0.0, cooldown_left - delta)
	velocity = Vector2.ZERO
	if stun_left > 0.0:
		stun_left = maxf(0.0, stun_left - delta)
		state = State.STUNNED
	else:
		_update_target()
		if not is_instance_valid(target):
			state = State.IDLE
		elif state == State.ATTACK:
			windup_left -= delta
			if windup_left <= 0.0:
				# Recheck distance and walls at impact; attacks do not track forever.
				if global_position.distance_to(target.global_position) <= attack_range and _can_see(target):
					if target.has_method("take_damage"):
						target.take_damage(attack_damage, global_position)
				cooldown_left = attack_cooldown
				state = State.CHASE
		else:
			var distance := global_position.distance_to(target.global_position)
			if distance <= attack_range and _can_see(target):
				state = State.IDLE
				if cooldown_left <= 0.0:
					state = State.ATTACK
					windup_left = attack_windup
			else:
				state = State.CHASE
				velocity = global_position.direction_to(target.global_position) * move_speed
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()
	sprite.modulate = Color.WHITE
	if state == State.ATTACK:
		sprite.modulate = Color(2.2, 0.7, 0.7)
	elif state == State.STUNNED:
		sprite.modulate = Color(2.0, 1.8, 0.6)
	queue_redraw()

func _update_target() -> void:
	if is_instance_valid(target):
		if target.get("current_health") != null and target.get("current_health") <= 0:
			target = null
		elif global_position.distance_to(target.global_position) > lose_target_radius:
			target = null
	if is_instance_valid(target):
		return
	var nearest_distance := detection_radius
	for candidate in get_tree().get_nodes_in_group("player"):
		if not candidate is Node2D:
			continue
		if candidate.get("current_health") != null and candidate.get("current_health") <= 0:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance <= nearest_distance and _can_see(candidate):
			target = candidate
			nearest_distance = distance

func _can_see(body: Node2D) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, body.global_position, 1, [get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == body

func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if defense_dormant or state == State.DEAD or amount <= 0:
		return
	health = maxi(0, health - amount)
	visual_motion.flash()
	health_changed.emit(health, max_health)
	if health == 0:
		state = State.DEAD
		visual_motion.dissolve_copy()
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		ENERGY_DROP.spawn_from(self)
		died.emit()
		queue_free()
		return
	if source_position != Vector2.ZERO:
		knockback = source_position.direction_to(global_position) * 160.0
	stun(0.15)

func stun(duration: float) -> void:
	if defense_dormant or state == State.DEAD or duration <= 0.0:
		return
	stun_left = maxf(stun_left, duration)
	state = State.STUNNED
	windup_left = 0.0
	cooldown_left = maxf(cooldown_left, 0.3)

func _draw() -> void:
	if defense_dormant:
		draw_arc(Vector2(0,-14),42,0,TAU,24,Color(0.65,0.55,1,0.45),2)
	draw_rect(Rect2(-20, -48, 40, 4), Color(0.15, 0.15, 0.2))
	draw_rect(Rect2(-20, -48, 40.0 * health / max_health, 4), Color(0.85, 0.3, 0.45))

func receive_hit(amount: int, source_position: Vector2) -> void:
	take_damage(amount, source_position)
