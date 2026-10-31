extends Node2D

func _ready() -> void:
	if scene_file_path.ends_with("forgotten_village.tscn") or scene_file_path.ends_with("ancient_beacon.tscn"):
		var ambience := preload("res://scripts/visuals/level_ambience.gd").new()
		ambience.name = "AmbientMotes"
		add_child.call_deferred(ambience)
	var encounters := preload("res://scripts/systems/encounters.gd").new()
	encounters.name = "Encounters"
	add_child.call_deferred(encounters)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		_on_pause_button_pressed()



func _on_pause_button_pressed() -> void:
	$PauseUI/PauseMenu.show()
	get_tree().paused = true
