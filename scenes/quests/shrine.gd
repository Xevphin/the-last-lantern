extends Area2D
## Proximity sensor shared by fragment altars and the existing golden shrine.
@export_enum("echo", "memory", "sacred") var shrine_id: String = "echo"
@export var shrine_title: String = "Shrine of Echoes"
@export var visual_path: NodePath = ^"Visual"
@export var light_color: Color = Color(0.45, 0.65, 1.0)
@export var light_energy: float = 0.65
var player_in_range: CharacterBody2D
var light: PointLight2D
var fragment: CanvasItem
var effect: Tween
var state: Node
const CORRUPTED_COLOR := Color(0.56, 0.25, 0.92)
var atmosphere: CanvasModulate
var restored_atmosphere: Color
var dark_atmosphere: Color
var restored_fragment: Color
var glow_time := 0.0

func _process(delta: float) -> void:
	glow_time += delta
	if not is_instance_valid(light) or (effect and effect.is_running()): return
	if shrine_id == "sacred" and state.activated:
		light.energy = 1.8 + sin(glow_time*1.8)*0.07

func _ready() -> void:
	add_to_group("quest_shrines")
	state = get_node("/root/ShrineQuestManager")
	var visual = get_node(visual_path)
	light = visual.get_node("UncollectedVisuals/SacredFlameLight")
	fragment = visual.get_node("UncollectedVisuals/GoldenFragment")
	restored_fragment = fragment.modulate
	if shrine_id == "sacred":
		atmosphere = get_node("../NightLighting")
		dark_atmosphere = atmosphere.color * Color(1,0.65,1)
		restored_atmosphere = atmosphere.color * Color(1.18,1.06,0.9)
	light.color = light_color
	if shrine_id != "sacred":
		fragment.modulate = light_color
	body_entered.connect(_entered)
	body_exited.connect(_exited)
	state.changed.connect(_refresh)
	_refresh()

func _entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		player_in_range = body

func _exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func available() -> bool:
	return is_instance_valid(player_in_range) and not get_tree().paused

func completed() -> bool:
	return state.activated if shrine_id == "sacred" else state.collected.has(shrine_id)

func _refresh() -> void:
	if shrine_id == "sacred" and state.activated and effect and effect.is_running(): return
	if effect and effect.is_valid():
		effect.kill()
	if shrine_id == "sacred":
		fragment.visible = true
		light.color = light_color if state.activated else CORRUPTED_COLOR
		fragment.modulate = restored_fragment if state.activated else CORRUPTED_COLOR
		atmosphere.color = restored_atmosphere if state.activated else dark_atmosphere
		light.energy = 1.8 if state.activated else light_energy
		light.texture_scale = 2.0
	else:
		fragment.visible = not completed()
		light.energy = 0.12 if completed() else light_energy

func interact() -> String:
	if not available():
		return ""
	if shrine_id == "sacred":
		if state.activated:
			return "The Sacred Flame has been restored."
		if state.count() < 2:
			return "The Sacred Flame is fading. Two lost fragments are required."
		return "confirm"
	if not state.collect(shrine_id):
		return "This fragment has already been collected."
	effect = create_tween()
	effect.tween_property(light, "energy", 1.05, 0.18)
	effect.tween_property(light, "energy", 0.12, 0.55)
	return "%s Fragment Collected — %d/2" % ["Echo" if shrine_id == "echo" else "Memory", state.count()]

func confirm_restoration() -> bool:
	if shrine_id != "sacred" or not available() or not state.restore():
		return false
	light.energy = light_energy
	light.texture_scale = 2.0
	light.color = CORRUPTED_COLOR
	fragment.modulate = CORRUPTED_COLOR
	atmosphere.color = dark_atmosphere
	effect = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	effect.tween_property(light, "color", light_color, 2.5)
	effect.tween_property(fragment, "modulate", restored_fragment, 2.5)
	effect.tween_property(atmosphere, "color", restored_atmosphere, 2.5)
	effect.tween_property(light, "energy", 2.3, 2.5)
	effect.tween_property(light, "texture_scale", 2.7, 2.5)
	effect.chain().tween_property(light, "energy", 1.8, 1.2)
	effect.parallel().tween_property(light, "texture_scale", 2.0, 1.2)
	return true
