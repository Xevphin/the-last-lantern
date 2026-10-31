extends Node2D
## Village/woods quest adapter. Player combat and existing menus remain separate.
@export var woods: bool = false
var state: Node
var player: CharacterBody2D
var target: Area2D
var pending: Area2D
var exit_area: Area2D
var exit_near: bool = false
var changing_scene: bool = false
var ui: CanvasLayer
var tracker: Label
var message: Label
var interact_button: Button
var confirm_row: HBoxContainer
var message_timer: Timer

func _ready() -> void:
	state = get_node("/root/ShrineQuestManager")
	var level := get_parent()
	player = level.get_node("Player")
	var map: Node2D = level.get_node("World") if woods else level
	player.global_position = map.get_node("PlayerSpawn").global_position
	if not state.next_spawn.is_empty():
		var arrival := map.get_node_or_null(state.next_spawn)
		if arrival: player.global_position = arrival.global_position
		state.next_spawn = ""
	if not woods and state.returning_to_village:
		player.global_position = map.get_node("WoodsExit").global_position + Vector2(0, 120)
		state.returning_to_village = false
	var camera: Camera2D = player.get_node("Camera2D")
	camera.reset_smoothing()
	camera.force_update_scroll()
	_build_ui()
	state.changed.connect(_update_tracker)
	_update_tracker()
	exit_area = Area2D.new()
	exit_area.name = "QuestExit"
	exit_area.collision_layer = 0
	exit_area.collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(220, 140)
	shape.shape = rect
	exit_area.add_child(shape)
	add_child(exit_area)
	exit_area.global_position = map.get_node("VillageReturn" if woods else "WoodsExit").global_position
	exit_area.body_entered.connect(func(body):
		if body == player: exit_near = true)
	exit_area.body_exited.connect(func(body):
		if body == player: exit_near = false)

func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.name = "ShrineQuestUI"
	ui.layer = 1 # Existing PauseUI on layer 2 stays above the quest.
	add_child(ui)
	tracker = Label.new()
	tracker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tracker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tracker.add_theme_color_override("font_color", Color(1,0.87,0.57))
	tracker.add_theme_color_override("font_shadow_color", Color.BLACK)
	tracker.add_theme_constant_override("shadow_offset_x", 2)
	tracker.add_theme_constant_override("shadow_offset_y", 2)
	tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(tracker)
	message = Label.new()
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message.add_theme_color_override("font_shadow_color", Color.BLACK)
	message.add_theme_constant_override("shadow_offset_x", 2)
	message.add_theme_constant_override("shadow_offset_y", 2)
	ui.add_child(message)
	interact_button = Button.new()
	interact_button.custom_minimum_size.y = 56
	interact_button.focus_mode = Control.FOCUS_NONE
	interact_button.pressed.connect(_interact)
	ui.add_child(interact_button)
	confirm_row = HBoxContainer.new()
	confirm_row.add_theme_constant_override("separation", 12)
	for caption in ["Confirm [E]", "Cancel"]:
		var button := Button.new()
		button.text = caption
		button.custom_minimum_size = Vector2(160, 56)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_confirm if caption.begins_with("Confirm") else _cancel)
		confirm_row.add_child(button)
	ui.add_child(confirm_row)
	confirm_row.hide()
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 7
	message_timer.timeout.connect(func(): message.text = "")
	add_child(message_timer)
	get_viewport().size_changed.connect(_layout_ui)
	_layout_ui()

func _layout_ui() -> void:
	var size := get_viewport_rect().size
	var vitals = player.get_node("GameHUD/ScreenRoot/PixelLayout/VitalsPanel")
	var left: float = vitals.get_global_rect().end.x + 16
	var width: float = maxf(260,size.x-left-110)
	tracker.position = Vector2(left,24)
	tracker.size = Vector2(width,54)
	message.position = Vector2(left,86)
	message.size = Vector2(width,90)
	interact_button.position = Vector2(size.x/2-180, size.y-92)
	interact_button.size = Vector2(360,64)
	confirm_row.position = Vector2(size.x/2-166, size.y-92)

func _update_tracker() -> void:
	tracker.text = "SACRED FLAME RESTORED" if state.activated else "LIGHT FRAGMENTS %d/2" % state.count()
	tracker.text += "  |  TREASURES %d/3" % state.treasures.size()

func _physics_process(_delta: float) -> void:
	if changing_scene:
		return
	var closest: Area2D = null
	var distance := INF
	for shrine in get_tree().get_nodes_in_group("quest_shrines"):
		if shrine.available():
			var d: float = player.global_position.distance_squared_to(shrine.global_position)
			if d < distance:
				distance = d
				closest = shrine
	target = closest
	if pending and (not is_instance_valid(pending) or not pending.available() or target != pending):
		_cancel()
	interact_button.visible = (target != null or exit_near) and pending == null
	if target:
		interact_button.text = "%s\n[E] / Click / Tap" % target.shrine_title
	elif exit_near:
		interact_button.text = ("Return to Forgotten Village" if woods else "Enter Whispering Woods") + "\n[E] / Click / Tap"

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		_interact()
		get_viewport().set_input_as_handled()

func _interact() -> void:
	if get_tree().paused or changing_scene:
		return
	if pending:
		_confirm()
	elif target and target.available():
		var result: String = target.interact()
		if result == "confirm":
			pending = target
			message_timer.stop()
			message.text = "Restore the Sacred Flame?"
			confirm_row.show()
			interact_button.hide()
		elif result.begins_with("travel:"):
			changing_scene = true
			call_deferred("_travel", result.trim_prefix("travel:"))
		elif not result.is_empty():
			_notify(result)
	elif exit_near:
		if not woods and not state.activated:
			_notify("The path is sealed. Restore the Sacred Flame to open Whispering Woods.")
			return
		changing_scene = true
		state.returning_to_village = woods
		var destination := "res://scenes/levels/forgotten_village.tscn" if woods else "res://scenes/levels/whispering_woods.tscn"
		call_deferred("_travel", destination)

func _travel(destination: String) -> void:
	var error := get_tree().change_scene_to_file(destination)
	if error != OK:
		changing_scene = false
		_notify("Unable to load the next area. Please try again.")

func _confirm() -> void:
	if get_tree().paused or not is_instance_valid(pending):
		return
	var shrine := pending
	_cancel()
	if shrine.confirm_restoration():
		_notify(shrine.restoration_message() if shrine.has_method("restoration_message") else "The Sacred Flame has been restored.\nThe path to Whispering Woods is now open.")

func _cancel() -> void:
	pending = null
	confirm_row.hide()
	message.text = ""

func _notify(text: String) -> void:
	message.text = text
	message_timer.start()

func _notification(what: int) -> void:
	if not is_node_ready(): return
	if what == NOTIFICATION_PAUSED:
		_cancel()
		ui.hide()
	elif what == NOTIFICATION_UNPAUSED:
		ui.show()
