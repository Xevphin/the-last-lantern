extends Control

#quit function
func _on_quit_button_pressed() -> void:
 get_tree().quit()

func _on_start_button_pressed() -> void:
 ShrineQuestManager.start_run()
 get_tree().change_scene_to_file("res://scenes/levels/forgotten_village.tscn")
	


func _on_settings_button_pressed() -> void:
 get_tree().change_scene_to_file("res://scenes/ui/setting_menu.tscn") # Replace with function body.

func _ready() -> void:
 add_child(preload("res://scripts/ui/menu_fit.gd").new())
 AudioSettings.apply()
