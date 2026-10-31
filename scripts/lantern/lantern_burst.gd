extends Node2D
## try_burst() can also be called by the future mobile Burst button.
signal burst_activated
const COST := 25
const COOLDOWN := 2.0
@export var radius: float = 180.0
@export var damage: int = 1
@export var stun_duration: float = 2.0
var cooldown_left: float = 0.0
var effect_left: float = 0.0
var pending_hit: bool = false
var burst_origin: Vector2
@onready var player: CharacterBody2D = get_parent()
@onready var lantern: Node = player.get_node("LanternSystem")

func try_burst() -> bool:
	if player.current_health <= 0 or cooldown_left > 0.0:
		return false
	if not lantern.spend_energy(COST):
		return false
	cooldown_left = COOLDOWN
	effect_left = 0.35
	burst_origin = player.global_position
	pending_hit = true
	burst_activated.emit()
	queue_redraw()
	return true

func _physics_process(delta: float) -> void:
	cooldown_left = maxf(0.0, cooldown_left - delta)
	effect_left = maxf(0.0, effect_left - delta)
	if pending_hit:
		pending_hit = false
		if player.current_health > 0:
			_apply_burst()
	queue_redraw()

func _apply_burst() -> void:
	# One pass per activation, with fixed world-space range independent of player scale.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if not enemy is Node2D or enemy.global_position.distance_to(burst_origin) > radius:
			continue
		var ray := PhysicsRayQueryParameters2D.create(burst_origin, enemy.global_position, 1, [player.get_rid()])
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, burst_origin)
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.has_method("stun"):
			enemy.stun(stun_duration)

func _draw() -> void:
	if effect_left <= 0.0:
		return
	# Draw in world units despite the current player scene's 3x scale.
	draw_set_transform_matrix(global_transform.affine_inverse())
	var alpha := effect_left / 0.35
	var ring_radius := radius * (1.0 - alpha * 0.8)
	draw_circle(burst_origin, radius, Color(0.96, 0.76, 0.36, alpha * 0.18))
	draw_arc(burst_origin, ring_radius, 0.0, TAU, 64, Color(1.0, 0.85, 0.45, alpha), 6.0)
	draw_set_transform_matrix(Transform2D.IDENTITY)
