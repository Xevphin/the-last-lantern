extends Node
## Mock values belong only to this preview, never to the production HUD.

var mock_health: int = 5
var mock_energy: float = 100.0
var mock_fragments: int = 0
@onready var hud: CanvasLayer = $GameHUD
var energy_slider: HSlider
var status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("111924")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var controls := CanvasLayer.new()
	controls.layer = 30
	add_child(controls)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_top = 112
	center.offset_bottom = -12
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controls.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 440
	column.add_theme_constant_override("separation", 6)
	center.add_child(column)
	var title := Label.new()
	title.text = "HUD PREVIEW — mock values only"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var health_row := HBoxContainer.new()
	column.add_child(health_row)
	_button(health_row, "Damage −1 HP", _damage, "Damage")
	_button(health_row, "Heal +1 HP", _heal, "Heal")
	var energy_row := HBoxContainer.new()
	column.add_child(energy_row)
	var energy_label := Label.new()
	energy_label.text = "Energy"
	energy_row.add_child(energy_label)
	energy_slider = HSlider.new()
	energy_slider.name = "MockEnergy"
	energy_slider.min_value = 0
	energy_slider.max_value = 100
	energy_slider.step = 1
	energy_slider.value = 100
	energy_slider.custom_minimum_size = Vector2(300, 40)
	energy_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	energy_slider.value_changed.connect(_energy_changed)
	energy_row.add_child(energy_slider)
	var fragment_row := HBoxContainer.new()
	column.add_child(fragment_row)
	_button(fragment_row, "Fragment −1", _remove_fragment, "RemoveFragment")
	_button(fragment_row, "Fragment +1", _add_fragment, "AddFragment")
	var options := HBoxContainer.new()
	column.add_child(options)
	_button(options, "Reset", _reset, "Reset")
	var safe_button := CheckButton.new()
	safe_button.name = "SafeMargins"
	safe_button.text = "Simulate screen cutout"
	safe_button.custom_minimum_size.y = 48
	safe_button.toggled.connect(_safe_margins_changed)
	options.add_child(safe_button)
	status = Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(status)
	_update_display()

func _button(parent: Control, caption: String, action: Callable, node_name: String) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = caption
	button.custom_minimum_size = Vector2(120, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	parent.add_child(button)

func _damage() -> void:
	mock_health = maxi(0, mock_health - 1)
	_update_display()

func _heal() -> void:
	mock_health = mini(5, mock_health + 1)
	_update_display()

func _energy_changed(value: float) -> void:
	mock_energy = value
	_update_display()

func _remove_fragment() -> void:
	mock_fragments = maxi(0, mock_fragments - 1)
	_update_display()

func _add_fragment() -> void:
	mock_fragments = mini(3, mock_fragments + 1)
	_update_display()

func _reset() -> void:
	mock_health = 5
	mock_energy = 100
	mock_fragments = 0
	energy_slider.set_value_no_signal(100)
	_update_display()

func _safe_margins_changed(enabled: bool) -> void:
	hud.extra_safe_margins = Vector4(60, 24, 40, 0) if enabled else Vector4.ZERO

func _update_display() -> void:
	hud.set_health(mock_health)
	hud.set_lantern_energy(mock_energy)
	hud.set_fragments(mock_fragments)
	if is_instance_valid(status):
		status.text = "Mock: %d HP  |  %d energy  |  %d fragments" % [mock_health, roundi(mock_energy), mock_fragments]
