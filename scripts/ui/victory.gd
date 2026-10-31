extends Control
func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("18212d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",30)
	center.add_child(box)
	var title := Label.new()
	title.text = "THE LAST LANTERN\n\nGame End (Wait for Updates)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",28)
	title.add_theme_color_override("font_color",Color("f5c25b"))
	box.add_child(title)
	var restart := Button.new()
	restart.text = "MAIN MENU"
	restart.custom_minimum_size.y = 60
	var style := StyleBoxFlat.new()
	style.bg_color = Color("192433")
	style.border_color = Color("bda15c")
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	restart.add_theme_stylebox_override("normal",style)
	restart.add_theme_color_override("font_color",Color("f5d38a"))
	restart.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	box.add_child(restart)
	# Don't give a held gameplay Space/Enter key an automatically focused button.
	restart.focus_mode = Control.FOCUS_ALL # Tab can focus it; gameplay input cannot.
