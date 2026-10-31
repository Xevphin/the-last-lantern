extends Node
## Limited procedural animation; affects the sprite only, never combat transforms.
var actor: Node2D
var visual: Node2D
var kind := "enemy"
var base_position: Vector2
var base_scale: Vector2
var elapsed := 0.0
var flash_left := 0.0
var material: ShaderMaterial
var pose_frames: Array[Texture2D] = []
var pose_index := 0
var walk_rig: Node2D

func configure(body: Node2D, sprite: Node2D, actor_kind: String) -> void:
	actor = body
	visual = sprite
	kind = actor_kind

func _ready() -> void:
	if kind != "boss":
		pose_frames = preload("res://scripts/visuals/adventurer_frames.gd").frames(-1 if kind == "player" else actor.art_row)
		visual.scale = Vector2.ONE
		visual.position = Vector2(0,-14)
		if visual is AnimatedSprite2D:
			var frames := SpriteFrames.new()
			frames.remove_animation("default")
			for animation in ["idle", "walk", "attack"]:
				frames.add_animation(animation)
				frames.set_animation_speed(animation, 12)
				if animation == "walk":
					for texture in preload("res://scripts/visuals/adventurer_frames.gd").walk_frames():
						frames.add_frame(animation,texture)
				elif animation == "idle":
					frames.add_frame(animation,preload("res://scripts/visuals/adventurer_frames.gd").walk_frames()[1])
				else: frames.add_frame(animation,pose_frames[3])
			visual.sprite_frames = frames
			visual.play("idle")
		else: visual.texture = pose_frames[0]
	base_position = visual.position
	base_scale = visual.scale
	material = ShaderMaterial.new()
	material.shader = preload("res://scripts/visuals/character.gdshader")
	visual.material = material
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if kind == "player":
		walk_rig = preload("res://scripts/visuals/keeper_walk_rig.gd").new()
		visual.add_child(walk_rig)
	if kind == "boss":
		var sheet := preload("res://assets/characters/divesh_poses.png").get_image()
		var cell := Vector2i(sheet.get_width()/4, sheet.get_height()/2)
		for index in range(8):
			var frame := sheet.get_region(Rect2i(Vector2i(index%4,index/4)*cell,cell))
			frame.resize(64,80,Image.INTERPOLATE_NEAREST)
			pose_frames.append(ImageTexture.create_from_image(frame))

func flash() -> void:
	flash_left = 0.16

func _process(delta: float) -> void:
	elapsed += delta
	flash_left = maxf(0, flash_left - delta)
	material.set_shader_parameter("hit_flash", minf(1, flash_left * 9))
	var state_name: String = "IDLE"
	if kind == "player":
		if actor.current_health <= 0: return
		state_name = "ATTACK" if actor.is_attacking else ("CHASE" if actor.animation_speed > 2 else "IDLE")
	else:
		state_name = actor.State.keys()[actor.state]
	if kind == "player":
		var animation := "attack" if state_name == "ATTACK" else "walk" if state_name == "CHASE" else "idle"
		if visual.animation != animation:
			visual.play(animation)
			visual.set_frame_and_progress(1 if animation == "walk" else 0,0.0)
		visual.speed_scale = clampf(actor.animation_speed/actor.move_speed,0.0,1.15) if state_name == "CHASE" else 1.0
		# Sprite flipping does not affect child Polygon2Ds: mirror the entire rig
		# separately so legs, torso and equipment face the same way as attacks.
		# Retain horizontal facing during vertical movement and when stopped.
		if absf(actor.facing_direction.x) > 0.15:
			visual.flip_h = actor.facing_direction.x < 0
		walk_rig.scale.x = -1.0 if visual.flip_h else 1.0
		walk_rig.visible = state_name != "ATTACK"
		visual.self_modulate.a = 0.0 if walk_rig.visible else 1.0
		walk_rig.advance(delta,actor.animation_speed if state_name == "CHASE" else 0.0)
	elif kind != "boss":
		pose_index = 3 if state_name == "ATTACK" else 1 + int(elapsed*7)%2 if state_name == "CHASE" else 0
		visual.texture = pose_frames[pose_index]
		if actor.velocity.x != 0: visual.flip_h = actor.velocity.x < 0
	if kind == "boss":
		pose_index = 0
		match state_name:
			"CHASE": pose_index = 1 + int(elapsed * 7) % 2
			"CHARGE_WARNING": pose_index = 3
			"CHARGE": pose_index = 4 if int(elapsed*10)%2 == 0 else 2
			"WAVE_WARNING": pose_index = 5
			"SHOCKWAVE": pose_index = 6
			"STUNNED": pose_index = 7
		visual.texture = pose_frames[pose_index]
	var offset := Vector2.ZERO
	var lean := 0.0
	var exposed := 0.0
	match state_name:
		"IDLE", "RECOVERY":
			if kind != "player": offset.y = roundf(sin(elapsed * 2.8)) * 2
		"CHASE":
			if kind != "player":
				offset.y = -absf(roundf(sin(elapsed * 12) * 3))
				lean = sin(elapsed * 12) * 0.045
		"ATTACK":
			var direction: Vector2 = actor.facing_direction if kind == "player" else actor.global_position.direction_to(actor.target.global_position) if is_instance_valid(actor.target) else Vector2.DOWN
			offset = direction * 5
			lean = direction.x * 0.12
		"CHARGE_WARNING":
			offset = -actor.charge_direction * 7 + Vector2(sin(elapsed*40)*2, 3)
			lean = -actor.charge_direction.x * 0.12
		"CHARGE":
			offset = actor.charge_direction * 10
			lean = actor.charge_direction.x * 0.2
		"WAVE_WARNING":
			offset.y = -6 - roundf(sin(elapsed * 8) * 2)
			exposed = 0.5 + sin(elapsed * 10) * 0.3
		"SHOCKWAVE":
			offset.y = 5
			exposed = 1
		"STUNNED":
			offset = Vector2(roundf(sin(elapsed * 25)*2), 4)
			lean = 0.1
			exposed = 0.7
	visual.position = base_position + offset.round()
	visual.rotation = lean
	material.set_shader_parameter("exposed", exposed)

func dissolve_copy() -> void:
	# A visual-only echo finishes death after the gameplay body is safely removed.
	var ghost := Sprite2D.new()
	ghost.texture = visual.sprite_frames.get_frame_texture(visual.animation, visual.frame) if visual is AnimatedSprite2D else visual.texture
	ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ghost.material = material.duplicate()
	ghost.process_mode = Node.PROCESS_MODE_ALWAYS
	actor.get_tree().current_scene.add_child(ghost)
	ghost.global_transform = visual.global_transform
	ghost.flip_h = visual.flip_h
	ghost.z_index = 20
	var tween := ghost.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(ghost, "position:y", ghost.position.y - 18, 0.65)
	tween.tween_method(func(value: float): ghost.material.set_shader_parameter("dissolve", value), 0.0, 1.0, 0.65)
	tween.chain().tween_callback(ghost.queue_free)
