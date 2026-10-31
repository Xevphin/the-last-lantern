extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func run() -> void:
	change_scene_to_file("res://scenes/levels/whispering_woods.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	var mist = current_scene.get_node("ForestMist")
	ck(mist.patches.size() > 0, "existing forest mist patches loaded")
	var first: Vector2 = mist.patches[0].position
	mist._process(5.0)
	ck(mist.patches[0].position != first, "mist visibly drifts")
	for i in mist.patches.size():
		ck(mist.patches[i].position.distance_to(mist.origins[i]) <= 5.1, "mist stays within bounded drift")
	var state = root.get_node("ShrineQuestManager")
	state.forest_shrine_activated = true
	var shrine = current_scene.get_node("ForestShrineInteraction")
	shrine._process(1.0)
	ck(shrine.light.energy >= 1.54 and shrine.light.energy <= 1.66, "restored forest glow is restrained")
	change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	var ambience = current_scene.get_node("AmbientMotes")
	ambience._process(2.0)
	for i in ambience.lamps.size():
		ck(absf(ambience.lamps[i].energy / ambience.base_energy[i] - 1) <= 0.036, "lantern flicker stays within 3.5 percent")
	state.activated = true
	shrine = current_scene.get_node("SacredFlameInteraction")
	shrine._process(1.0)
	ck(shrine.light.energy >= 1.73 and shrine.light.energy <= 1.87, "restored village glow is restrained")
	ck(ambience.mist.size() == 4,"village mist capped at four faint patches")
	change_scene_to_file("res://scenes/levels/ancient_beacon.tscn")
	await scene_changed
	for i in range(8): await physics_frame
	ambience = current_scene.get_node("AmbientMotes")
	state.boss_defeated = true
	await create_timer(2.2).timeout
	ck(ambience.victory_glow and ambience.arena_light.color.is_equal_approx(Color("f5c25b")),"boss defeat changes arena accents to gold")
	ck(is_equal_approx(ambience.arena_light.energy,0.65),"post-boss glow remains bounded")
	print("ATMOSPHERE CHECKS failures=",failures)
	quit(failures)
