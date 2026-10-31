extends Control

func _ready() -> void:
	# Retain the existing controls and art; make room for Master and Music Mute.
	$SettingTitle.position.y = 36
	var master_label := $MusicLabel.duplicate(0) as Label
	master_label.name = "MasterLabel"
	master_label.text = "MASTER VOLUME"
	master_label.position.y = 130
	master_label.size.y = 40
	add_child(master_label)
	var master_slider := $MusicSlider.duplicate(0) as HSlider
	master_slider.name = "MasterSlider"
	master_slider.position.y = 170
	add_child(master_slider)
	var master_value := $MusicPercentageLabel.duplicate(0) as Label
	master_value.name = "MasterPercentageLabel"
	master_value.position.y = 170
	add_child(master_value)
	$MusicLabel.position.y = 230
	$MusicLabel.size.y = 40
	$MusicLabel.text = "MUSIC VOLUME"
	$MusicSlider.position.y = 270
	$MusicPercentageLabel.position.y = 270
	$SFXLabel.position.y = 330
	$SFXLabel.size.y = 40
	$SFXLabel.text = "SOUND EFFECTS"
	$SFXSlider.position.y = 370
	$SFXPercentageLabel.position.y = 370
	var mute := CheckButton.new()
	mute.name = "MusicMute"
	mute.text = "Mute music"
	mute.position = Vector2(426,440)
	mute.size = Vector2(300,48)
	mute.add_theme_color_override("font_color",Color("f5d38a"))
	add_child(mute)
	master_slider.value_changed.connect(_on_master_changed)
	mute.toggled.connect(_on_music_mute)
	load_audio_settings()
	add_child(preload("res://scripts/ui/menu_fit.gd").new())
	visibility_changed.connect(func():
		if visible: load_audio_settings())

func _on_master_changed(value: float) -> void:
	AudioSettings.master = value
	$MasterPercentageLabel.text = "%d%%" % roundi(value)
	save_audio_settings()
func _on_music_slider_value_changed(value: float) -> void:
	AudioSettings.music = value
	$MusicPercentageLabel.text = "%d%%" % roundi(value)
	save_audio_settings()
func _on_sfx_slider_value_changed(value: float) -> void:
	AudioSettings.sfx = value
	$SFXPercentageLabel.text = "%d%%" % roundi(value)
	save_audio_settings()
func _on_music_mute(value: bool) -> void:
	AudioSettings.music_muted = value
	save_audio_settings()
func save_audio_settings() -> void:
	AudioSettings.apply()
	var error := AudioSettings.save()
	if error != OK: push_warning("Audio settings could not be saved: %s" % error_string(error))
func load_audio_settings() -> void:
	$MasterSlider.set_value_no_signal(AudioSettings.master)
	$MusicSlider.set_value_no_signal(AudioSettings.music)
	$SFXSlider.set_value_no_signal(AudioSettings.sfx)
	$MusicMute.set_pressed_no_signal(AudioSettings.music_muted)
	$MasterPercentageLabel.text = "%d%%" % roundi(AudioSettings.master)
	$MusicPercentageLabel.text = "%d%%" % roundi(AudioSettings.music)
	$SFXPercentageLabel.text = "%d%%" % roundi(AudioSettings.sfx)
func _on_back_button_pressed() -> void:
	var parent := get_parent()
	if parent.name == "PauseUI":
		hide()
		parent.get_node("PauseMenu").show()
	else: get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
