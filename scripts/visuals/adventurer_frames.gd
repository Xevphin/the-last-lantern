extends RefCounted
## One-time sheet sampling, cached across scene travel. No image work per tick.
static var cache: Dictionary = {}
static func walk_frames() -> Array[Texture2D]:
	if cache.has("walk"): return cache["walk"]
	var sheet: Image = preload("res://assets/characters/keeper_walk_cycle.png").get_image()
	var cell := Vector2i(sheet.get_width()/3, sheet.get_height()/2)
	var result: Array[Texture2D] = []
	for index in range(6):
		var frame := sheet.get_region(Rect2i(Vector2i(index%3,index/3)*cell,cell))
		frame.resize(80,80,Image.INTERPOLATE_NEAREST)
		result.append(ImageTexture.create_from_image(frame))
	cache["walk"] = result
	return result
static func frames(kind: int) -> Array[Texture2D]:
	if cache.has(kind): return cache[kind]
	var sheet: Image = (load("res://assets/characters/keeper_realistic_poses.png") if kind == -1 else load("res://assets/characters/monsters_realistic_poses.png")).get_image()
	var columns := 2 if kind == -1 else 4
	var cell := Vector2i(sheet.get_width()/columns, sheet.get_height()/columns)
	var result: Array[Texture2D] = []
	for index in range(4):
		var origin := Vector2i(index%2,index/2) if kind == -1 else Vector2i(index,kind)
		var frame := sheet.get_region(Rect2i(origin*cell,cell))
		frame.resize(80,80,Image.INTERPOLATE_NEAREST)
		result.append(ImageTexture.create_from_image(frame))
	cache[kind] = result
	return result
