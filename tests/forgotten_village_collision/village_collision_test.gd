extends Node2D

func _ready() -> void:
	var spawn := get_node_or_null("ForgottenVillage/PlayerSpawn") as Marker2D
	var character := $TestCharacter as CharacterBody2D
	if spawn == null:
		character.set_physics_process(false)
		push_error("Collision test: ForgottenVillage/PlayerSpawn is missing.")
		return
	character.global_position = spawn.global_position
	var camera := character.get_node("Camera2D") as Camera2D
	camera.make_current()
	camera.reset_smoothing()
	camera.force_update_scroll()


func _on_pause_button_pressed() -> void:
	$PauseUI/PauseMenu.show()
	get_tree().paused = true 
