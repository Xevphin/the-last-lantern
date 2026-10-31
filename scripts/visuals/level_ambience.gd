extends Node2D
## A few drifting motes and gentle existing-lamp flicker; no scenery/collisions.
var elapsed := 0.0
var lamps: Array[PointLight2D] = []
var base_energy: Array[float] = []
var village := false
var arena_light: PointLight2D
var mist: Array[Sprite2D] = []
var mist_origins: Array[Vector2] = []
var victory_glow := false

func _ready() -> void:
	village = get_parent().scene_file_path.ends_with("forgotten_village.tscn")
	var material := CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	self.material = material
	if village:
		for lamp in get_parent().get_node("VillageLight").get_children():
			if lamp is PointLight2D:
				lamps.append(lamp)
				base_energy.append(lamp.energy)
		var fog_gradient := Gradient.new()
		fog_gradient.colors = PackedColorArray([Color(0.48,0.57,0.65,0.045),Color(0.48,0.57,0.65,0)])
		var fog_texture := GradientTexture2D.new()
		fog_texture.gradient = fog_gradient
		fog_texture.width = 64
		fog_texture.height = 64
		fog_texture.fill = GradientTexture2D.FILL_RADIAL
		fog_texture.fill_from = Vector2(0.5,0.5)
		fog_texture.fill_to = Vector2(1,0.5)
		for point in [Vector2(650,460),Vector2(2900,650),Vector2(900,1500),Vector2(2750,1600)]:
			var patch := Sprite2D.new()
			patch.texture = fog_texture
			patch.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			patch.material = material
			patch.position = point
			patch.scale = Vector2(5,2)
			add_child(patch)
			mist.append(patch)
			mist_origins.append(point)
	else:
		var light := PointLight2D.new()
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color(1,1,1,0.8), Color(1,1,1,0)])
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.width = 256
		texture.height = 256
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5,0.5)
		texture.fill_to = Vector2(0.5,0)
		light.texture = texture
		light.texture_scale = 5
		light.color = Color("b6a9df")
		light.energy = 0.45
		light.position = Vector2(1152,850)
		add_child(light)
		arena_light = light

func _process(delta: float) -> void:
	elapsed += delta
	for i in lamps.size():
		lamps[i].energy = base_energy[i] * (1 + sin(elapsed*2.4+i)*0.035)
	for i in mist.size(): mist[i].position = mist_origins[i] + Vector2(sin(elapsed*0.1+i)*12,cos(elapsed*0.08+i)*5)
	if not village and not victory_glow and get_node("/root/ShrineQuestManager").boss_defeated:
		victory_glow = true
		var glow := create_tween().set_parallel(true)
		glow.tween_property(arena_light,"color",Color("f5c25b"),2.0)
		glow.tween_property(arena_light,"energy",0.65,2.0)
	queue_redraw()

func _draw() -> void:
	for i in range(36 if village else 20):
		var point := Vector2(500 + fmod(i*179.0,2700), 300 + fmod(i*113.0,1450)) if village else Vector2(850+fmod(i*179.0,600),550+fmod(i*113.0,600))
		point += Vector2(sin(elapsed*0.35+i)*22, sin(elapsed*0.5+i*2)*12)
		var alpha := 0.12 + (sin(elapsed*1.4+i)*0.5+0.5)*0.35
		draw_rect(Rect2(point.round(),Vector2(2,2)),Color(1,0.85,0.5,alpha))
