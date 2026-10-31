extends Area2D
## Automatically collected by a living player, including at full energy.
@export var energy_amount: int = 15
var collecting: bool = false

func _ready() -> void:
	add_to_group("energy_pickups")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collecting or not body.is_in_group("player"):
		return
	if body.get("current_health") != null and body.get("current_health") <= 0:
		return
	var lantern := body.get_node_or_null("LanternSystem")
	if lantern == null or not lantern.has_method("restore_energy"):
		return
	collecting = true
	lantern.restore_energy(energy_amount)
	queue_free()
