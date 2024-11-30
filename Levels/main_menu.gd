extends Control

const CLASS_ROOM := "res://Levels/class_room.tscn"

@onready var bully_desk: DeskBully = $BullyDesk
@onready var play_button: Button = %PlayButton

func _ready() -> void:
	bully_desk.taunt()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(CLASS_ROOM)
