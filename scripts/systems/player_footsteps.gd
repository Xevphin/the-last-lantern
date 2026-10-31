extends Node
## Observes the existing walk phase; does not change animation or movement.
const BANKS := {
	"gravel":["gravel.ogg"],
	"forest":["leaves01.ogg","leaves02.ogg","mud02.ogg"],
	"leaves":["leaves01.ogg","leaves02.ogg"],
	"mud":["mud02.ogg"],
	"stone":["stone01.ogg"],
	"wood":["wood01.ogg","wood02.ogg","wood03.ogg"]
}
var actor: CharacterBody2D
var player: AudioStreamPlayer
var streams: Array[AudioStream] = []
var surface := "gravel"
var last_phase := 0.0
var variation := 0
var steps := 0
func _ready() -> void:
	actor = get_parent()
	player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.volume_db = -20
	player.max_polyphony = 1
	add_child(player)
	_configure.call_deferred()
func _configure() -> void:
	var level := actor.get_parent()
	var file := level.scene_file_path.get_file()
	if file.ends_with("interior.tscn"): surface = "wood"
	elif file == "whispering_woods.tscn": surface = "forest"
	elif file == "ancient_beacon.tscn": surface = "stone"
	# Optional future surface metadata, without modifying existing TileMaps.
	surface = str(level.get_meta("footstep_surface",surface))
	if not BANKS.has(surface): surface = "gravel"
	for filename in BANKS[surface]:
		var path: String = "res://assets/audio/sfx/"+filename
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path).duplicate()
			stream.loop = false
			streams.append(stream)
		else: push_warning("Missing footstep: " + path)
func _process(_delta: float) -> void:
	var phase: float = actor.visual_motion.walk_rig.phase
	var advanced := fposmod(phase-last_phase,TAU)
	var moving: bool = actor.current_health > 0 and actor.is_physics_processing() and actor.animation_speed > 2 and not actor.is_attacking and actor.knockback_velocity.length() <= 10
	if moving and advanced > 0 and advanced < PI:
		for contact in [PI/2,PI*1.5]:
			var until_contact := fposmod(contact-last_phase,TAU)
			if until_contact > 0 and until_contact <= advanced: _step()
	elif not moving: player.stop()
	last_phase = phase
func _step() -> void:
	if streams.is_empty(): return
	player.stream = streams[variation % streams.size()]
	variation += 1
	player.pitch_scale = randf_range(0.96,1.04)
	player.play()
	steps += 1
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and is_instance_valid(player): player.stop()
