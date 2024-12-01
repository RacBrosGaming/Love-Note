extends Control

const MAIN_MENU := "res://Levels/main_menu.tscn"

@export var game_stats: GameStats

@onready var quit_button: Button = %QuitButton
@onready var start_desk: Desk = $StartDesk
@onready var end_desk: Desk = $EndDesk
@onready var bully_desk: DeskBully = $BullyDesk

func _ready() -> void:
	if game_stats.answer:
		start_desk.direction = Vector2.RIGHT
		end_desk.direction = Vector2.LEFT
	else:
		var end_desk_position := end_desk.global_position
		var bully_position := bully_desk.global_position
		end_desk.global_position = bully_position
		bully_desk.global_position = end_desk_position
		start_desk.wait_for_results()
		start_desk.set_result(game_stats.answer)
	bully_desk.taunt(false)
	match OS.get_name():
		"Windows","macOS", "Linux":
			quit_button.disabled = false
			quit_button.show()
		"Android", "iOS", "Web", _:
			quit_button.hide()
			quit_button.disabled = true

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
