extends RefCounted
## Guaranteed one-pickup drops for testing. Called only after the enemy enters DEAD.
const PICKUP_SCENE = preload("res://scenes/pickups/energy_pickup.tscn")

static func spawn_from(enemy: Node2D) -> void:
	var container: Node = enemy.get_tree().current_scene
	if container == null:
		container = enemy.get_parent().get_parent()
	if container == null or container.is_queued_for_deletion():
		return
	var pickup := PICKUP_SCENE.instantiate() as Node2D
	pickup.position = container.to_local(enemy.global_position) if container is Node2D else enemy.global_position
	# Defeats can occur during physics callbacks, so defer changing the scene tree.
	container.add_child.call_deferred(pickup)
