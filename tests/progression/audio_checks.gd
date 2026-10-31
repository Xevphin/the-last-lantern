extends SceneTree
var failures := 0
var music: Node
func _initialize() -> void: call_deferred("run")
func ck(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames(n: int = 8) -> void:
	for i in range(n): await physics_frame
	await process_frame
func travel(path: String, key: String) -> void:
	change_scene_to_file("res://"+path)
	await scene_changed
	await ready_track(key)
func ready_track(key: String) -> void:
	for i in range(80):
		await create_timer(0.025).timeout
		if music.current_key == key and music.playing_path == music.TRACKS[key] and music.player.playing: break
	ck(music.current_key == key and music.playing_path == music.TRACKS[key] and music.player.playing,"correct music: "+key)
func run() -> void:
	music = root.get_node("MusicDirector")
	var sfx = root.get_node("SoundEffects")
	for path in music.TRACKS.values(): ck(ResourceLoader.exists(path),"music resource imported: "+path.get_file())
	for bank in preload("res://scripts/systems/player_footsteps.gd").BANKS.values():
		for file in bank: ck(ResourceLoader.exists("res://assets/audio/sfx/"+file),"footstep imported: "+file)
	ck(sfx.click_player.stream != null and sfx.click_player.bus == "SFX","click loaded on SFX bus")
	await travel("scenes/ui/main_menu.tscn","menu")
	await create_timer(0.7).timeout
	var start_count: int = music.starts
	var stream_id: int = music.player.stream.get_instance_id()
	var position: float = music.player.get_playback_position()
	var clicks: int = sfx.clicks
	current_scene.get_node("StartButton").pressed.emit()
	await scene_changed
	await frames()
	ck(sfx.clicks == clicks+1,"Start activation clicks exactly once across scene change")
	ck(music.starts == start_count and music.player.stream.get_instance_id() == stream_id and music.player.get_playback_position() >= position,"Menu to Village preserves track and playback position")
	ck(music.player.stream.loop and music.player.bus == "Music","exploration loops on Music bus")
	var p = current_scene.get_node("Player")
	var feet = p.get_node("Footsteps")
	for e in get_nodes_in_group("enemies"): e.set_physics_process(false)
	ck(feet.surface == "gravel","village gravel default")
	Input.action_press("move_right")
	await create_timer(0.8).timeout
	ck(feet.steps >= 2 and feet.steps <= 4,"foot contacts follow existing gait")
	ck(feet.player.pitch_scale >= 0.96 and feet.player.pitch_scale <= 1.04 and feet.player.max_polyphony == 1,"quiet bounded footstep variation")
	Input.action_release("move_right")
	await frames()
	var steps: int = feet.steps
	await create_timer(0.2).timeout
	ck(feet.steps == steps and not feet.player.playing,"stopping stops footsteps")
	paused = true
	await create_timer(0.2).timeout
	ck(music.player.playing and feet.steps == steps,"pause keeps music and stops feet")
	paused = false
	var joystick = p.get_node("MobileControls/VirtualJoystick")
	var origin: Vector2 = joystick.get_global_transform_with_canvas()*joystick.center
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = origin
	touch.pressed = true
	root.push_input(touch,true)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = origin+Vector2(70,0)
	root.push_input(drag,true)
	await create_timer(0.7).timeout
	ck(feet.steps > steps,"virtual joystick movement produces synchronized footsteps")
	p.perform_attack()
	await frames(2)
	steps = feet.steps
	await frames(5)
	ck(feet.steps == steps and not feet.player.playing,"attack interrupts footsteps")
	touch = InputEventScreenTouch.new()
	touch.index = 0
	touch.position = origin
	touch.pressed = false
	root.push_input(touch,true)
	await create_timer(0.4).timeout
	p.take_damage(1,p.global_position-Vector2(100,0))
	await frames(3)
	ck(feet.steps == steps and not feet.player.playing,"knockback does not produce steps")
	p.heal(1)
	var state = root.get_node("ShrineQuestManager")
	state.collect("echo")
	state.collect("memory")
	state.restore()
	await frames()
	ck(music.starts == start_count,"shrine restoration does not restart forest music")
	await travel("scenes/levels/whispering_woods.tscn","woods")
	await frames()
	feet = current_scene.get_node("Player/Footsteps")
	ck(feet.surface == "forest" and feet.streams.size() == 3,"woods alternates leaves and soft mud")
	var first: AudioStream
	feet._step()
	first = feet.player.stream
	feet._step()
	ck(feet.player.stream != first,"footstep variations alternate")
	await travel("scenes/quests/hunters_lodge_interior.tscn","woods")
	await frames()
	feet = current_scene.get_node("Player/Footsteps")
	ck(feet.surface == "wood" and feet.streams.size() == 3,"house wood variations")
	await travel("scenes/levels/ancient_beacon.tscn","beacon")
	await frames()
	ck(current_scene.get_node("Player/Footsteps").surface == "stone","beacon stone default")
	ck(music.player.stream is AudioStreamMP3 and music.player.stream.loop,"beacon MP3 loops")
	start_count = music.starts
	current_scene.get_node("Encounters").engaged = true
	await frames()
	ck(music.current_key == "boss" and music.starts == start_count,"defenders to DIVESH continues demon lord")
	state.boss_defeated = true
	await frames()
	ck(music.current_key == "beacon" and music.starts == start_count,"boss defeat and restoration preserve arena music")
	await travel("scenes/ui/victory.tscn","ending")
	ck(music.player.stream is AudioStreamWAV and music.player.stream.loop_mode == AudioStreamWAV.LOOP_DISABLED,"ending WAV plays once")
	start_count = music.starts
	# Audio drains on its own mixer clock; allow buffering under concurrent tests.
	var deadline := Time.get_ticks_msec()+int((music.player.stream.get_length()+3.0)*1000)
	while music.player.playing and Time.get_ticks_msec() < deadline:
		await create_timer(0.05).timeout
	await create_timer(0.3).timeout
	ck(not music.player.playing and music.starts == start_count and current_scene.name == "Victory","fanfare finishes once; ending stays visible")
	clicks = sfx.clicks
	current_scene.find_children("*","Button",true,false)[0].pressed.emit()
	await scene_changed
	await ready_track("menu")
	ck(sfx.clicks == clicks+1,"ending Main Menu clicks once")
	state.start_run()
	await travel("scenes/levels/forgotten_village.tscn","village")
	p = current_scene.get_node("Player")
	p.take_damage(5,Vector2.ZERO)
	await ready_track("defeat")
	ck(paused and music.player.stream is AudioStreamMP3 and music.player.stream.loop,"death loops Dark Loop over defeat screen")
	var defeat = get_nodes_in_group("audio_defeat_screen")[0]
	clicks = sfx.clicks
	defeat.find_children("*","Button",true,false)[0].pressed.emit()
	await scene_changed
	await ready_track("village")
	ck(not paused and sfx.clicks == clicks+1,"retry resumes level music and clicks once")
	p = current_scene.get_node("Player")
	p.take_damage(5,Vector2.ZERO)
	await ready_track("defeat")
	defeat = get_nodes_in_group("audio_defeat_screen")[0]
	defeat.find_children("*","Button",true,false)[1].pressed.emit()
	await scene_changed
	await ready_track("menu")
	# Exercise real Settings callbacks and persistence in an isolated test file.
	var settings = root.get_node("AudioSettings")
	var original := [settings.master,settings.music,settings.sfx,settings.music_muted,settings.settings_path]
	settings.settings_path = "res://tests/progression/reports/audio-settings-test.cfg"
	await travel("scenes/ui/setting_menu.tscn","menu")
	current_scene.get_node("MasterSlider").value = 82
	current_scene.get_node("MusicSlider").value = 47
	current_scene.get_node("SFXSlider").value = 73
	current_scene.get_node("MusicMute").button_pressed = true
	ck(is_equal_approx(AudioServer.get_bus_volume_linear(0),0.82),"Master slider controls Master")
	ck(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music")),0.47),"Music slider controls Music")
	ck(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")),0.73),"SFX slider controls SFX")
	ck(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) and not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),"music mute leaves effects unmuted")
	var saved := ConfigFile.new()
	ck(saved.load(settings.settings_path) == OK and saved.get_value("audio","music") == 47 and saved.get_value("audio","music_muted"),"settings persist through ConfigFile")
	settings.master = original[0]
	settings.music = original[1]
	settings.sfx = original[2]
	settings.music_muted = original[3]
	settings.settings_path = original[4]
	settings.apply()
	music.set_process(false)
	start_count = music.starts
	music.select("woods")
	music.select("beacon")
	music.select("woods")
	await ready_track("woods")
	ck(music.starts == start_count+1,"rapid navigation cancels stale music transitions")
	music.set_process(true)
	ck(music.get_child_count() == 1,"one music player throughout full audio progression")
	print("AUDIO CHECKS failures=",failures)
	quit(failures)
