extends CanvasLayer

func _ready() -> void:
	add_to_group("audio_defeat_screen")
	layer = 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.05, 0.1, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)
	var title := Label.new()
	title.text = "THE FLAME FLICKERS\n\nYour discoveries are safe. Try this area again."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	for caption in ["Retry Area", "Main Menu"]:
		var button := Button.new()
		button.text = caption
		button.custom_minimum_size = Vector2(360, 64)
		box.add_child(button)
		button.pressed.connect(_leave.bind(caption == "Retry Area"))
	box.get_child(1).grab_focus()
	get_tree().paused = true

func _leave(retry: bool) -> void:
	remove_from_group("audio_defeat_screen")
	get_tree().paused = false
	if retry:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
