extends Camera2D
## World bounds, not a screen-space cover. Geometry and spawn points are unchanged.
var map_size := Vector2.ZERO
func _ready() -> void:
	_configure.call_deferred()
func _configure() -> void:
	var level := get_parent().get_parent()
	match level.scene_file_path.get_file():
		"forgotten_village.tscn": map_size = Vector2(3456,1944)
		"whispering_woods.tscn", "ancient_beacon.tscn": map_size = Vector2(2304,1536)
	if map_size == Vector2.ZERO: return
	limit_left = 0
	limit_top = 0
	limit_right = int(map_size.x)
	limit_bottom = int(map_size.y)
	limit_smoothed = false
	get_viewport().size_changed.connect(_fit_view)
	_fit_view()
	# Designer labels are retained in the editor, hidden only during gameplay.
	for guide in level.find_children("GuideLabels","Node2D",true,false): guide.hide()
	if not OS.is_debug_build(): get_tree().debug_collisions_hint = false
func _fit_view() -> void:
	var size := get_viewport_rect().size
	var fit := maxf(1.0,maxf(size.x/map_size.x,size.y/map_size.y))
	zoom = Vector2.ONE * fit
	reset_smoothing()
	force_update_scroll()
