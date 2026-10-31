extends Node2D
## Desktop environment preview. Boss, collection and saving are deliberately external.

@export var speed: float = 220.0
var overview := false
var restored_preview := false
var marker_labels: Node2D
var label_timer := 0.0

@onready var beacon: Node2D = $AncientBeacon
@onready var character: CharacterBody2D = $TestCharacter
@onready var camera: Camera2D = $TestCharacter/Camera2D
@onready var states: AnimationPlayer = $AncientBeacon/VisualStates
@onready var instructions: Label = $PreviewHUD/Panel/Instructions

func _ready() -> void:
	character.global_position = beacon.get_node("PlayerSpawn").global_position
	camera.make_current()
	camera.reset_smoothing()
	create_marker_labels()
	update_instructions()

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	)
	character.velocity = direction.normalized() * speed
	character.move_and_slide()
	label_timer += delta
	if label_timer >= 0.2:
		label_timer = 0
		update_instructions()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_G:
			restored_preview = true
			states.play("restored")
		KEY_C:
			restored_preview = false
			states.play("corrupted")
		KEY_R:
			character.global_position = beacon.get_node("PlayerSpawn").global_position
			camera.reset_smoothing()
		KEY_O:
			overview = not overview
			camera.zoom = Vector2(0.45,0.45) if overview else Vector2(0.85,0.85)
		KEY_M:
			marker_labels.visible = not marker_labels.visible
		KEY_ESCAPE:
			get_tree().quit()
	update_instructions()

func create_marker_labels() -> void:
	marker_labels = Node2D.new()
	marker_labels.name = "PreviewMarkerLabels"
	marker_labels.z_index = 20
	add_child(marker_labels)
	var material := CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	for marker_name in ["PlayerSpawn", "BossSpawn", "FragmentObjective", "BeaconCore"]:
		var marker: Marker2D = beacon.get_node(marker_name)
		var label := Label.new()
		label.name = marker_name + "Label"
		label.text = "+ " + marker_name
		label.position = marker.global_position + Vector2(12,-12)
		label.material = material
		label.modulate = Color(0.55,0.78,0.87,0.85)
		label.add_theme_font_size_override("font_size",14)
		marker_labels.add_child(label)

func update_instructions() -> void:
	var location := "Walk north through the ruined gateway into the boss arena."
	if character.global_position.distance_to(beacon.get_node("BossSpawn").global_position) < 112:
		location = "Boss staging point reached. No boss is spawned in this preview."
	if character.global_position.distance_to(beacon.get_node("FragmentObjective").global_position) < 88:
		location = "Altar approach reached. G restores the visuals; C returns to corruption."
	var state := "Restored preview" if restored_preview else "Corrupted preview"
	instructions.text = "ANCIENT BEACON — " + state + "\nWASD/arrows: move | G: restore | C: corrupt | R: spawn\nO: overview | M: marker labels | Esc: close\n" + location
