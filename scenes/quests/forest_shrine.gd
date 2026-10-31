extends "res://scenes/quests/forest_interaction.gd"
var light: PointLight2D
var effect: Tween
const CORRUPTED_COLOR := Color(0.56, 0.25, 0.92)
var fragment: CanvasItem
var atmosphere: CanvasModulate
var restored_light: Color
var restored_fragment: Color
var restored_atmosphere: Color
var glow_time := 0.0

func _process(delta: float) -> void:
	glow_time += delta
	if not is_instance_valid(light) or (effect and effect.is_running()): return
	if state.forest_unlocked(): light.energy = 1.6 + sin(glow_time*1.8)*0.06
func _ready() -> void:
	super._ready()
	light = get_node("../SacredFlameShrine/UncollectedVisuals/SacredFlameLight")
	fragment = get_node("../SacredFlameShrine/UncollectedVisuals/GoldenFragment")
	atmosphere = get_node("../NightLighting")
	restored_light = light.color
	restored_fragment = fragment.modulate
	restored_atmosphere = atmosphere.color
	if not state.forest_unlocked():
		light.color = CORRUPTED_COLOR
		fragment.modulate = CORRUPTED_COLOR
		atmosphere.color = restored_atmosphere * Color(1, 0.65, 1)
	light.energy = 1.6 if state.forest_unlocked() else 0.65
func interact() -> String:
	if not available(): return ""
	if state.forest_unlocked(): return "The forest shrine is restored. The Beacon route is open."
	if state.forest_completed.size() != 2:
		return "Find the Lantern Relic and read the Keeper's Journal to awaken this shrine."
	return "confirm"
func confirm_restoration() -> bool:
	if not available() or not state.restore_forest(): return false
	effect = create_tween().set_parallel(true)
	effect.tween_property(light,"color",restored_light,0.7)
	effect.tween_property(fragment,"modulate",restored_fragment,0.7)
	effect.tween_property(atmosphere,"color",restored_atmosphere,0.7)
	effect.tween_property(light,"energy",2.1,0.7)
	effect.chain().tween_property(light,"energy",1.6,1.3)
	return true
func restoration_message() -> String:
	return "The forest shrine has awakened.\nThe route to Ancient Beacon is now open."
