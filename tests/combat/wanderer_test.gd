extends Node2D
var status: Label
var enemy: CharacterBody2D
func _ready() -> void:
	enemy = $ShadowWanderer/CharacterBody2D
	# The inherited hidden dummy is disabled only in this test.
	var dummy := get_node_or_null("Player/DummyTarget")
	if dummy: dummy.queue_free()
	var canvas := CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)
	status = Label.new()
	status.position = Vector2(370,18)
	canvas.add_child(status)
	var restart := Button.new()
	restart.text = "Restart test"
	restart.position = Vector2(18,180)
	restart.custom_minimum_size = Vector2(160,56)
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	canvas.add_child(restart)
func _process(_delta: float) -> void:
	var enemy_text := str(enemy.health) if is_instance_valid(enemy) else "defeated"
	status.text = "PHASE 2 — Wanderer combat (temporary artwork)\nWASD / joystick | Space / sword button\nPlayer HP: %d/5 | Wanderer HP: %s | K / flame: Burst (25 energy, 2s)" % [$Player.current_health, enemy_text]
