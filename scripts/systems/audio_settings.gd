extends Node
## Shares the existing settings file; never resets other stored sections.
const SETTINGS_PATH := "user://settings.cfg"
var settings_path := SETTINGS_PATH
var master := 85.0
var music := 60.0
var sfx := 80.0
var music_muted := false
var config := ConfigFile.new()
func _ready() -> void:
	load_settings()
func load_settings() -> void:
	config.load(settings_path)
	master = clampf(float(config.get_value("audio","master",master)),0,100)
	music = clampf(float(config.get_value("audio","music",music)),0,100)
	sfx = clampf(float(config.get_value("audio","sfx",sfx)),0,100)
	music_muted = bool(config.get_value("audio","music_muted",false))
	apply()
func apply() -> void:
	for entry in [["Master",master],["Music",music],["SFX",sfx]]:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(entry[0]),entry[1]/100.0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),music_muted)
func save() -> Error:
	config.set_value("audio","master",master)
	config.set_value("audio","music",music)
	config.set_value("audio","sfx",sfx)
	config.set_value("audio","music_muted",music_muted)
	return config.save(settings_path)
