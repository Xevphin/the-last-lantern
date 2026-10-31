extends SceneTree
## Render the new Settings layout and record real decoded music + click output.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1152,648)
	change_scene_to_file("res://scenes/ui/setting_menu.tscn")
	await scene_changed
	await create_timer(1.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/progression/reports/audio_settings.png")
	var record := AudioEffectRecord.new()
	AudioServer.add_bus_effect(0,record)
	var index := AudioServer.get_bus_effect_count(0)-1
	record.set_recording_active(true)
	await create_timer(0.5).timeout
	root.get_node("SoundEffects").play_click()
	await create_timer(2.0).timeout
	record.set_recording_active(false)
	var output := record.get_recording()
	var error := output.save_to_wav("res://tests/progression/reports/audio_mix_preview.wav")
	print("AUDIO MIX RECORDING error=",error," seconds=",output.get_length())
	AudioServer.remove_bus_effect(0,index)
	root.size = Vector2i(960,540)
	for i in range(10): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/progression/reports/audio_settings_small.png")
	quit(error)
