extends Node
## Fit the authored 1152x648 menu without moving or replacing its controls.
var items: Dictionary = {}
func _ready() -> void:
	var menu := get_parent()
	if not menu.has_node("Background") and not menu.has_node("DarkOverlay"):
		var backdrop := ColorRect.new()
		backdrop.name = "Background"
		backdrop.color = Color("101827")
		backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		menu.add_child(backdrop)
		menu.move_child(backdrop,0)
	for child in menu.get_children():
		if child is Control and child.name not in ["Background","DarkOverlay"]:
			items[child] = child.position
			if child is Button and not child.has_theme_stylebox_override("normal"):
				var style := StyleBoxFlat.new()
				style.bg_color = Color("192433")
				style.border_color = Color("bda15c")
				style.set_border_width_all(2)
				style.set_corner_radius_all(6)
				child.add_theme_stylebox_override("normal",style)
				var hover := style.duplicate()
				hover.bg_color = Color("344358")
				child.add_theme_stylebox_override("hover",hover)
				child.add_theme_stylebox_override("pressed",hover)
				child.add_theme_color_override("font_color",Color("f5d38a"))
	get_viewport().size_changed.connect(_layout)
	_layout()
func _layout() -> void:
	var size := get_viewport().get_visible_rect().size
	var factor := minf(size.x/1152.0,size.y/648.0)
	var offset := (size-Vector2(1152,648)*factor)/2
	for item in items:
		item.position = offset + items[item]*factor
		item.scale = Vector2.ONE*factor
