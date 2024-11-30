extends Control

const CLASS_ROOM := "res://Levels/class_room.tscn"

@export var game_stats: GameStats

@onready var quit_button: Button = %QuitButton
@onready var start_desk: Desk = $StartDesk
@onready var end_desk: Desk = $EndDesk
@onready var desk_bully: DeskBully = $DeskBully

func _ready() -> void:
	if game_stats.answer:
		start_desk.direction = Vector2.RIGHT
		end_desk.direction = Vector2.LEFT
	else:
		var end_desk_position := end_desk.global_position
		var bully_position := desk_bully.global_position
		end_desk.global_position = bully_position
		desk_bully.global_position = end_desk_position
		start_desk.wait_for_results()
		start_desk.set_result(game_stats.answer)
	desk_bully.taunt()
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
