extends Node2D
## Slow, low-opacity drift kept inside the existing solid woodland footprint.
var elapsed := 0.0
var origins: Array[Vector2] = []
var patches: Array[Sprite2D] = []
func _ready() -> void:
	z_index = 4
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.45,0.55,0.60,0.28))
	gradient.set_color(1, Color(0.45,0.55,0.60,0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 64
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5,0.5)
	texture.fill_to = Vector2(1,0.5)
	var material := CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	self.material = material
	for body in get_node("../Boundaries").get_children():
		if not body.name.begins_with("Thicket") and not body.name.begins_with("PocketThicket"): continue
		var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision == null or not collision.shape is RectangleShape2D: continue
		var dimensions: Vector2 = collision.shape.size
		if dimensions.x < 48 or dimensions.y < 48: continue
		var mist := Sprite2D.new()
		mist.texture = texture
		mist.material = material
		mist.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		mist.position = to_local(collision.global_position)
		mist.scale = dimensions * 0.8 / 64.0
		add_child(mist)
		origins.append(mist.position)
		patches.append(mist)

func _process(delta: float) -> void:
	elapsed += delta
	for i in patches.size():
		patches[i].position = origins[i] + Vector2(sin(elapsed*0.18+i)*4, cos(elapsed*0.13+i)*3)
		patches[i].modulate.a = 0.75 + sin(elapsed*0.24+i)*0.12
	queue_redraw()

func _draw() -> void:
	# A bounded handful of fireflies near existing thickets, never a particle emitter.
	for i in mini(14,origins.size()):
		var point := origins[i] + Vector2(sin(elapsed*0.4+i)*18,cos(elapsed*0.3+i)*10)
		var alpha := maxf(0,sin(elapsed*0.7+i*2))*0.3
		draw_circle(point,1.5,Color(0.9,0.83,0.45,alpha))
