extends Node2D
## Local movement preview only. Does not use or change the team's player systems.

@export var speed: float = 180.0
var elapsed: float = 0.0

@onready var woods: Node2D = $WhisperingWoods
@onready var character: CharacterBody2D = $TestCharacter
@onready var status: Label = $TestHUD/Panel/Instructions

func _ready() -> void:
	character.global_position = woods.get_node("PlayerSpawn").global_position
	var camera: Camera2D = character.get_node("Camera2D")
	camera.make_current()
	camera.reset_smoothing()
	update_status()

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	character.velocity = direction.normalized() * speed
	character.move_and_slide()
	elapsed += delta
	if elapsed >= 0.2:
		elapsed = 0.0
		update_status()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			character.global_position = woods.get_node("PlayerSpawn").global_position
		if event.physical_keycode == KEY_G:
			var states: AnimationPlayer = woods.get_node("SacredFlameShrine/VisualStates")
			var light: PointLight2D = woods.get_node("SacredFlameShrine/UncollectedVisuals/SacredFlameLight")
			states.play("collected" if light.enabled else "uncollected")
			states.advance(0.0)
			update_status()

func update_status() -> void:
	var place := "Follow the winding path north; the shrine branch turns east."
	for marker_name in ["AncientBeaconExit", "FragmentObjective", "Encounter01", "Encounter02"]:
		var point: Marker2D = woods.get_node(marker_name)
		if character.global_position.distance_to(point.global_position) < 100:
			match marker_name:
				"AncientBeaconExit": place = "Ancient Beacon exit reached (transition reserved for integration)."
				"FragmentObjective": place = "Shrine reached. G previews the fragment's visual state."
				"Encounter01", "Encounter02": place = "Encounter clearing: " + marker_name + " (enemy placement reserved)."
	status.text = "WOODS MOVEMENT TEST\nWASD / arrows: move | R: spawn | G: shrine preview | Esc: close\n" + place
