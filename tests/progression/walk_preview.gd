extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(960,200)
	root.content_scale_size = root.size
	root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	var stage := Node2D.new()
	root.add_child(stage)
	var frames = preload("res://scripts/visuals/adventurer_frames.gd").walk_frames()
	for i in range(6):
		var sprite := Sprite2D.new()
		sprite.texture = frames[i]
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://scripts/visuals/character.gdshader")
		sprite.material = mat
		sprite.scale = Vector2(2,2)
		sprite.position = Vector2(80+i*160,100)
		stage.add_child(sprite)
	for i in range(12): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/progression/reports/walk_preview.png")
	quit()
