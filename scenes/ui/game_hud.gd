extends CanvasLayer
## Display only. Gameplay systems supply values through the three public setters.
## Cached values permit updates before the scene is added to the tree.

const MAX_HEALTH: int = 5
const MAX_ENERGY: float = 100.0
const MAX_FRAGMENTS: int = 3
const HEART_FILLED: Texture2D = preload("res://assets/ui/hud/heart_filled.svg")
const HEART_EMPTY: Texture2D = preload("res://assets/ui/hud/heart_empty.svg")

## Additional layout margins in viewport pixels: left, top, right, bottom.
## Useful for embedding or testing cutout clearance without changing gameplay.
@export var extra_safe_margins: Vector4 = Vector4.ZERO:
	set(value):
		extra_safe_margins = Vector4(maxf(value.x,0),maxf(value.y,0),maxf(value.z,0),maxf(value.w,0))
		if is_node_ready():
			_layout_hud()

var _display_health: int = MAX_HEALTH
var _display_energy: float = MAX_ENERGY
var _display_fragments: int = 0

@onready var _screen_root: Control = $ScreenRoot
@onready var _pixel_layout: Control = $ScreenRoot/PixelLayout
@onready var _hearts: HBoxContainer = $ScreenRoot/PixelLayout/VitalsPanel/Margin/Vitals/Hearts
@onready var _energy_bar: ProgressBar = $ScreenRoot/PixelLayout/VitalsPanel/Margin/Vitals/EnergyBar
@onready var _energy_value: Label = $ScreenRoot/PixelLayout/VitalsPanel/Margin/Vitals/EnergyCaption/EnergyValue
@onready var _fragment_value: Label = $ScreenRoot/PixelLayout/FragmentPanel/Margin/Row/Caption/FragmentValue

func _ready() -> void:
	_ignore_input(_screen_root)
	get_viewport().size_changed.connect(_layout_hud)
	_refresh_health()
	_refresh_energy()
	_refresh_fragments()
	_layout_hud()

func set_health(current_hp: int) -> void:
	_display_health = clampi(current_hp,0,MAX_HEALTH)
	if is_node_ready():
		_refresh_health()

func set_lantern_energy(value: float) -> void:
	# Keep the last valid display if a caller supplies NaN or infinity.
	if not is_finite(value):
		return
	_display_energy = clampf(value,0.0,MAX_ENERGY)
	if is_node_ready():
		_refresh_energy()

func set_fragments(count: int) -> void:
	_display_fragments = clampi(count,0,MAX_FRAGMENTS)
	if is_node_ready():
		_refresh_fragments()

func _refresh_health() -> void:
	for index in range(MAX_HEALTH):
		var heart: TextureRect = _hearts.get_child(index)
		heart.texture = HEART_FILLED if index < _display_health else HEART_EMPTY
	_hearts.tooltip_text = "Health: %d/%d" % [_display_health,MAX_HEALTH]

func _refresh_energy() -> void:
	_energy_bar.value = _display_energy
	_energy_value.text = "%d/100" % roundi(_display_energy)

func _refresh_fragments() -> void:
	_fragment_value.text = "%d/3" % _display_fragments

func _ignore_input(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children():
		_ignore_input(child)

func _device_safe_rect() -> Rect2:
	var visible: Rect2 = get_viewport().get_visible_rect()
	# Desktop previews and embedded SubViewports use their own bounds. On Android,
	# convert the physical display's safe rectangle into this fullscreen canvas.
	if OS.has_feature("android") and get_viewport() is Window:
		var window_id: int = get_window().get_window_id()
		var screen: int = DisplayServer.window_get_current_screen(window_id)
		var safe := Rect2(DisplayServer.get_display_safe_area())
		var native_size := Vector2(DisplayServer.window_get_size(window_id))
		var native_origin := Vector2(DisplayServer.window_get_position(window_id) - DisplayServer.screen_get_position(screen))
		if native_size.x > 0 and native_size.y > 0:
			var overlap: Rect2 = safe.intersection(Rect2(native_origin,native_size))
			if overlap.has_area():
				var ratio: Vector2 = visible.size / native_size
				return Rect2(visible.position + (overlap.position-native_origin)*ratio,overlap.size*ratio)
	return visible

func _layout_hud() -> void:
	var safe: Rect2 = _device_safe_rect()
	safe.position += Vector2(extra_safe_margins.x,extra_safe_margins.y)
	safe.size -= Vector2(extra_safe_margins.x+extra_safe_margins.z,extra_safe_margins.y+extra_safe_margins.w)
	if safe.size.x < 320 or safe.size.y < 180:
		safe = get_viewport().get_visible_rect()
	# Cancel canvas stretch before choosing an integer physical-pixel scale.
	# Otherwise e.g. the default 1152-wide canvas stretched to 1280 would turn
	# a 2x heart into a blurry/uneven 2.22x heart. Camera zoom does not affect us.
	var stretch: Vector2 = get_viewport().get_stretch_transform().get_scale()
	stretch = stretch.max(Vector2(0.001, 0.001))
	var physical_size: Vector2 = safe.size * stretch
	var pixel_scale: int = clampi(roundi(minf(physical_size.x/640.0,physical_size.y/360.0)),1,4)
	pixel_scale = mini(pixel_scale,maxi(1,floori(physical_size.x/320.0)))
	_pixel_layout.scale = Vector2.ONE * pixel_scale / stretch
	_pixel_layout.position = (safe.position * stretch + Vector2(12,12)*pixel_scale).round() / stretch
	_pixel_layout.size = (physical_size / pixel_scale).floor() - Vector2(24,24)
