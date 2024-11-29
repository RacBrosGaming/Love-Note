extends Control

var CLASS_ROOM := "res://Levels/class_room.tscn"

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file(CLASS_ROOM)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
