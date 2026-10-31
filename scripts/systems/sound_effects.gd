extends Node
## Persistent click playback survives scene-changing button callbacks.
const CLICK := "res://assets/audio/sfx/Menu Selection Click.wav"
var click_player: AudioStreamPlayer
var clicks := 0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	click_player = AudioStreamPlayer.new()
	click_player.bus = "SFX"
	click_player.volume_db = -10
	click_player.max_polyphony = 2
	if ResourceLoader.exists(CLICK):
		click_player.stream = load(CLICK).duplicate()
		click_player.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	else: push_warning("Missing sound effect: " + CLICK)
	add_child(click_player)
	get_tree().node_added.connect(_connect_button)
func _connect_button(node: Node) -> void:
	if node is Button and not node.pressed.is_connected(play_click): node.pressed.connect(play_click)
func play_click() -> void:
	if click_player.stream:
		click_player.play()
		clicks += 1
