extends Node2D
## Small texture mesh: existing keeper art, stable torso, independent lower legs.
## UVs stay fixed; only the mesh vertices move. No image generation at runtime.
var phase := 0.0
var stride := 0.0
var near_leg: Polygon2D
var far_leg: Polygon2D
var near_uv: PackedVector2Array
var far_uv: PackedVector2Array
var foot_offsets := Vector2.ZERO

func _ready() -> void:
	var texture := preload("res://scripts/visuals/adventurer_frames.gd").walk_frames()[1]
	# All coordinates refer to the original 80x80 texture, centered at (40,40).
	far_uv = PackedVector2Array([Vector2(28,54),Vector2(42,54),Vector2(43,62),Vector2(43,70),Vector2(43,78),Vector2(25,78),Vector2(25,70),Vector2(25,62)])
	near_uv = PackedVector2Array([Vector2(42,54),Vector2(57,54),Vector2(57,62),Vector2(57,70),Vector2(57,78),Vector2(42,78),Vector2(42,70),Vector2(42,62)])
	far_leg = _piece(texture,far_uv)
	near_leg = _piece(texture,near_uv)
	# Cape, sword, head, torso and lantern never get leg deformation.
	_piece(texture,PackedVector2Array([Vector2(0,0),Vector2(80,0),Vector2(80,54),Vector2(34,54),Vector2(34,59),Vector2(0,59)]))
	advance(0,0)

func _piece(texture: Texture2D, coords: PackedVector2Array) -> Polygon2D:
	var piece := Polygon2D.new()
	piece.texture = texture
	piece.uv = coords
	var points := coords.duplicate()
	for i in points.size(): points[i] -= Vector2(40,40)
	piece.polygon = points
	piece.material = get_parent().material
	piece.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(piece)
	return piece

func advance(delta: float, speed: float) -> void:
	# One stride per 72 world pixels; horizontal and diagonal speeds agree.
	if speed > 2: phase = fmod(phase + speed * delta * TAU / 72.0,TAU)
	stride = move_toward(stride,1.0 if speed > 2 else 0.0,delta*10)
	var step := sin(phase)*stride
	foot_offsets = Vector2(-5.0+step*8.0,4.0-step*8.0)
	_deform(near_leg,near_uv,foot_offsets.x,maxf(0,cos(phase))*-3*stride,0)
	_deform(far_leg,far_uv,foot_offsets.y,maxf(0,-cos(phase))*-3*stride,5)

func _deform(piece: Polygon2D, coords: PackedVector2Array, travel: float, lift: float, baseline: float) -> void:
	var points := coords.duplicate()
	for i in points.size():
		var weight := clampf((coords[i].y-54.0)/18.0,0,1)
		points[i] += Vector2(travel,baseline+lift)*weight - Vector2(40,40)
	piece.polygon = points
