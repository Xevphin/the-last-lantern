extends Control

func _ready() -> void:
 add_child(preload("res://scripts/ui/menu_fit.gd").new())

func _on_resume_button_pressed() -> void:
 get_tree().paused = false
 hide()


# Replace with function body.


func _on_main_menu_button_pressed() -> void:
 get_tree().paused = false
 get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")# Replace with function body.


func _on_setting_button_pressed() -> void:
 get_parent().get_node("SettingMenu").show()
 hide()
# Replace with function body.
