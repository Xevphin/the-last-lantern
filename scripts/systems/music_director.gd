extends Node
## One authoritative player. Shared tracks survive context changes without restart.
const TRACKS := {
	"menu":"res://assets/audio/music/forest.ogg",
	"village":"res://assets/audio/music/forest.ogg",
	"woods":"res://assets/audio/music/cave themeb4.ogg",
	"beacon":"res://assets/audio/music/demon lord.mp3",
	"boss":"res://assets/audio/music/demon lord.mp3",
	"ending":"res://assets/audio/music/Game Over II ~ v3.wav",
	"defeat":"res://assets/audio/music/Dark Loop.mp3"
}
const BACKGROUND_DB := -12.0
var player: AudioStreamPlayer
var current_key := ""
var requested_path := ""
var playing_path := ""
var starts := 0
var revision := 0
var transition: Tween
var missing_reported: Dictionary = {}
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)
func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if not is_instance_valid(scene): return
	var key := current_key
	match scene.scene_file_path.get_file():
		"main_menu.tscn", "setting_menu.tscn": key = "menu"
		"forgotten_village.tscn", "village_ember_vial_interior.tscn", "village_guardian_sigil_interior.tscn", "village_keeper_charm_interior.tscn": key = "village"
		"whispering_woods.tscn", "hunters_lodge_interior.tscn", "keepers_house_interior.tscn": key = "woods"
		"ancient_beacon.tscn":
			var encounters := scene.get_node_or_null("Encounters")
			key = "boss" if encounters and encounters.engaged and not get_node("/root/ShrineQuestManager").boss_defeated else "beacon"
		"victory.tscn": key = "ending"
	if not get_tree().get_nodes_in_group("audio_defeat_screen").is_empty(): key = "defeat"
	if key != current_key: select(key)
func select(key: String) -> void:
	current_key = key
	var path: String = TRACKS.get(key,"")
	# Also preserves an in-progress fade and a completed non-looping fanfare.
	if path == requested_path: return
	requested_path = path
	revision += 1
	var ticket := revision
	if transition and transition.is_valid(): transition.kill()
	transition = create_tween()
	if player.playing: transition.tween_property(player,"volume_db",-60.0,0.5)
	transition.tween_callback(func():
		player.stop()
		player.stream = null
		playing_path = ""
		_finish_transition(path,key,ticket))

func _finish_transition(path: String, key: String, ticket: int) -> void:
	# Load only after releasing the previous stream. Drain cancelled loads too.
	if not path.is_empty() and ResourceLoader.exists(path): ResourceLoader.load_threaded_request(path,"AudioStream")
	while not path.is_empty() and ResourceLoader.exists(path) and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	if path.is_empty(): return
	if not ResourceLoader.exists(path) or ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		if not missing_reported.has(path):
			missing_reported[path] = true
			push_warning("Music unavailable: " + path)
		return
	var loaded := ResourceLoader.load_threaded_get(path) as AudioStream
	if ticket != revision: return
	var stream := loaded.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3: stream.loop = key != "ending"
	if stream is AudioStreamWAV: stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	player.stream = stream
	playing_path = path
	player.volume_db = -60
	player.play()
	starts += 1
	transition = create_tween()
	transition.tween_property(player,"volume_db",-8.0 if key == "ending" else BACKGROUND_DB,0.5)
