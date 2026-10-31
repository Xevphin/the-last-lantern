extends Node2D
## Adds encounters only; existing maps, quests and menus remain the owners of travel.
const WANDERER = preload("res://scenes/enemies/divesh/ShadowWanderer.tscn")
const STALKER = preload("res://scenes/enemies/divesh/ShadowStalker.tscn")
const BRUTE = preload("res://scenes/enemies/divesh/MossBrute.tscn")
const IMP = preload("res://scenes/enemies/divesh/AshImp.tscn")
const GUARDIAN = preload("res://scenes/bosses/ShadowGuardian.tscn")
const PICKUP = preload("res://scenes/pickups/energy_pickup.tscn")
var boss: CharacterBody2D
var boss_label: Label
var engaged := false
var player: CharacterBody2D
var level: Node2D
var state: Node
var defenders: Array[CharacterBody2D] = []
var defense_started := false
var defense_wave := -1
var intermission := 0.0

func _ready() -> void:
	level = get_parent()
	player = level.get_node("Player")
	state = get_node("/root/ShrineQuestManager")
	# Wait for world collision shapes before validating placements.
	await get_tree().physics_frame
	await get_tree().physics_frame
	match level.scene_file_path.get_file():
		"forgotten_village.tscn":
			for point in [Vector2(1728,1400), Vector2(1100,850), Vector2(2200,1150), Vector2(1728,650)]:
				_spawn_enemy(WANDERER, point)
			for point in [Vector2(1728,1660), Vector2(2700,1150)]: _pickup(point)
			_spawn_enemy(BRUTE,Vector2(2500,900))
			_spawn_enemy(IMP,Vector2(1250,1250))
			_spawn_enemy(IMP,Vector2(3000,1350))
		"whispering_woods.tscn":
			for point in [Vector2(576,1120), Vector2(1056,736), Vector2(1648,400)]:
				_spawn_enemy(WANDERER, point)
			for point in [Vector2(850,1000), Vector2(1648,800)]:
				_spawn_enemy(STALKER, point)
			for point in [Vector2(576,1280), Vector2(1500,736)]: _pickup(point)
			_spawn_enemy(BRUTE,Vector2(1900,950))
			_spawn_enemy(IMP,Vector2(1150,520))
			_spawn_enemy(IMP,Vector2(1320,736))
		"ancient_beacon.tscn":
			_setup_beacon()

func _free_position(desired: Vector2, radius: float = 24.0) -> Vector2:
	var circle := CircleShape2D.new()
	circle.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	for ring in range(9):
		for direction in range(16):
			var point := desired + Vector2.from_angle(direction * TAU / 16) * ring * 32.0
			query.transform = Transform2D(0, point)
			if get_world_2d().direct_space_state.intersect_shape(query).is_empty(): return point
	push_warning("No free encounter position near %s" % desired)
	return desired

func _spawn_enemy(scene: PackedScene, point: Vector2) -> void:
	var id := "%s:%s" % [level.scene_file_path, point]
	if state.defeated_enemies.has(id): return
	var enemy := scene.instantiate()
	enemy.position = _free_position(point)
	add_child(enemy)
	enemy.get_node("CharacterBody2D").died.connect(func(): state.defeated_enemies[id] = true)

func _pickup(point: Vector2) -> void:
	var pickup := PICKUP.instantiate()
	pickup.position = _free_position(point, 18)
	add_child(pickup)

func _setup_beacon() -> void:
	var objective := Area2D.new()
	objective.name = "FinalBeacon"
	objective.set_script(preload("res://scripts/systems/final_beacon.gd"))
	objective.position = level.get_node("FragmentObjective").position
	objective.collision_layer = 0
	objective.collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 85
	shape.shape = circle
	objective.add_child(shape)
	add_child(objective)
	if state.beacon_restored:
		level.get_node("VisualStates").play("restored")
		level.get_node("VisualStates").seek(2.0, true)
	if state.boss_defeated: return
	var guardian := GUARDIAN.instantiate()
	guardian.position = level.get_node("BossSpawn").position
	guardian.get_node("CharacterBody2D").encounter_locked = true
	add_child(guardian)
	boss = guardian.get_node("CharacterBody2D")
	boss.set_physics_process(false)
	boss.boss_defeated.connect(_boss_defeated)
	_setup_defenders()
	var ui := CanvasLayer.new()
	add_child(ui)
	boss_label = Label.new()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	boss_label.offset_top = get_viewport_rect().size.y - 170
	boss_label.add_theme_color_override("font_color", Color("f5c25b"))
	ui.add_child(boss_label)
	for point in [Vector2(912,1000), Vector2(1392,1000), Vector2(1152,1190)]: _pickup(point)

func _process(delta: float) -> void:
	if is_instance_valid(boss_label): boss_label.offset_top = get_viewport_rect().size.y - 170
	if not is_instance_valid(boss): return
	if player.current_health <= 0: return
	if not engaged:
		if not defense_started and player.global_position.y < 1180:
			defense_started = true
			_activate_next_wave()
		if defense_started:
			intermission = maxf(0, intermission-delta)
			var active := defenders.filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion() and not e.defense_dormant)
			if active.is_empty() and intermission <= 0: _activate_next_wave()
		if not engaged:
			var left := defenders.filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion()).size()
			boss_label.text = "DIVESH'S DEFENDERS • %d remaining\n%s" % [left, "Wave %d / 2 • Defeat the unshielded guards first." % (defense_wave+1) if defense_started else "Enter the arena to challenge his defenders"]
			return
	boss_label.text = "DIVESH  •  %d / %d\n%s" % [boss.health, boss.max_health,
		"Dodge the red warnings. Burst interrupts attacks." if engaged else "Approach the altar to face DIVESH"]

func _setup_defenders() -> void:
	var formation := preload("res://assets/encounters/beacon_defenders.tscn").instantiate()
	# Give each defender a stable name-based persistence key, independent of tuning positions.
	for holder in formation.get_children():
		var id := "beacon_guard:" + str(holder.name)
		if state.defeated_enemies.has(id):
			holder.queue_free()
			continue
		var body: CharacterBody2D = holder.get_node("CharacterBody2D")
		body.defense_dormant = true
		body.set_meta("defense_wave",holder.get_meta("defense_wave"))
		body.add_to_group("beacon_defenders")
		holder.position = _free_position(holder.position)
		body.set_physics_process(false)
		body.died.connect(func():
			state.defeated_enemies[id] = true
			intermission = 1.5)
		defenders.append(body)
	add_child(formation)
	for guard in defenders: guard.set_physics_process(false)

func _activate_next_wave() -> void:
	for wave in range(defense_wave+1,2):
		var remaining := defenders.filter(func(e): return is_instance_valid(e) and not e.is_queued_for_deletion() and e.get_meta("defense_wave") == wave)
		if remaining.is_empty(): continue
		defense_wave = wave
		for guard in remaining:
			guard.defense_dormant = false
			guard.target = player
			guard.detection_radius = 1800
			guard.lose_target_radius = 2200
			guard.set_physics_process(true)
		return
	engaged = true
	boss.encounter_locked = false
	boss.set_physics_process(true)
	# Modest one-time breather, rather than a full heal on every re-entry.
	if not state.defeated_enemies.has("beacon_defense_reward"):
		state.defeated_enemies["beacon_defense_reward"] = true
		player.heal(2)
		player.get_node("LanternSystem").restore_energy(25)
	if state.has_treasure("guardian_sigil"): boss.take_damage(3, player.global_position)
	if state.has_treasure("ember_vial"): player.get_node("LanternSystem").restore_energy(100)
	if state.has_treasure("keeper_charm"): player.heal(5)

func _boss_defeated() -> void:
	state.boss_defeated = true
	state.changed.emit()
	boss_label.text = "DIVESH DEFEATED\nRestore the Beacon [E / Tap]"
	player.heal(5)
