extends RefCounted
## Isolate boss unit/duel tests from the separately tested defender encounter.
static func cleared_state(tree: SceneTree) -> void:
	var state := tree.root.get_node("ShrineQuestManager")
	for name in ["WestWatch","EastWatch","Vanguard","WestClaw","EastClaw","AltarGuard"]:
		state.defeated_enemies["beacon_guard:"+name] = true
