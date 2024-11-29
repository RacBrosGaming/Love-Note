extends Control

var CLASS_ROOM := "res://Levels/class_room.tscn"
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	match OS.get_name():
		"Windows","macOS", "Linux":
			quit_button.disabled = false
			quit_button.show()
		"Android", "iOS", "Web", _:
			quit_button.hide()
			quit_button.disabled = true

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file(CLASS_ROOM)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
