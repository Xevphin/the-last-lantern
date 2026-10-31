extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(960,200)
	root.content_scale_size = root.size
	for i in range(6):
		var holder := Node2D.new()
		holder.position = Vector2(80+i*160,100)
		holder.scale = Vector2(2,2)
		root.add_child(holder)
		var rig = preload("res://scripts/visuals/keeper_walk_rig.gd").new()
		holder.add_child(rig)
		rig.stride = 1
		rig.phase = i*TAU/6
		rig.advance(0,130)
	for i in range(8): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/progression/reports/rig_contacts.png")
	quit()
