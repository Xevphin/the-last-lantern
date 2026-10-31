extends CanvasLayer
## Keep the controls in the lower safe corners; all hit shapes and art share
## the same origin and scale. No player or input-map changes are needed.

const REFERENCE_SIZE := Vector2(1152, 648)
var _reference_positions: Dictionary = {}
var _reference_scales: Dictionary = {}

func _ready() -> void:
	# Read the editor's saved layout once, before applying viewport scaling.
	for control in [$AttackButton, $BurstButton, $VirtualJoystick]:
		_reference_positions[control.name] = control.position
		_reference_scales[control.name] = control.scale
	get_viewport().size_changed.connect(_layout)
	_layout()
	for button in [$AttackButton, $BurstButton]:
		button.pressed.connect(_highlight.bind(button, true))
		button.released.connect(_highlight.bind(button, false))

func _highlight(button: TouchScreenButton, pressed: bool) -> void:
	button.modulate = Color(1.25, 1.18, 1.05) if pressed else Color.WHITE

func _layout() -> void:
	var rect := get_viewport().get_visible_rect()
	var stretch := get_viewport().get_stretch_transform().get_scale()
	var screen_size := rect.size * stretch
	var safe := Rect2(Vector2.ZERO, screen_size)
	if OS.has_feature("android"):
		var area := Rect2(DisplayServer.get_display_safe_area())
		var overlap := safe.intersection(area)
		if overlap.has_area():
			safe = overlap
	var factor := minf(safe.size.x / REFERENCE_SIZE.x, safe.size.y / REFERENCE_SIZE.y)
	# Uniform physical sizing preserves the screenshot proportions. Cancel the
	# project's canvas stretch so editor zoom never enters the calculation.
	for button in [$AttackButton, $BurstButton]:
		var reference_position: Vector2 = _reference_positions[button.name]
		button.scale = _reference_scales[button.name] * factor / stretch
		button.position = (safe.end - (REFERENCE_SIZE - reference_position) * factor) / stretch
	$VirtualJoystick.set_anchors_preset(Control.PRESET_TOP_LEFT)
	var joystick_position: Vector2 = _reference_positions[&"VirtualJoystick"]
	$VirtualJoystick.scale = _reference_scales[&"VirtualJoystick"] * factor / stretch
	$VirtualJoystick.position = (Vector2(safe.position.x, safe.end.y) + Vector2(joystick_position.x, joystick_position.y - REFERENCE_SIZE.y) * factor) / stretch

func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_PAUSED:
		# Hiding a TouchScreenButton releases its held action.
		hide()
	elif what == NOTIFICATION_UNPAUSED:
		show()
