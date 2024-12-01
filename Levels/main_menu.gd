extends Control

const CLASS_ROOM := "res://Levels/class_room.tscn"

@export var game_stats: GameStats

@onready var bully_desk: DeskBully = $BullyDesk
@onready var play_button: Button = %PlayButton
@onready var bell: Polygon2D = $Bell
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var bell_activate_count := 5
var bell_click_count := 0
var bell_activated := false

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	bully_desk.taunt(false)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(CLASS_ROOM)

func _on_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch) && event.is_released():
		var bell_clicked := Geometry2D.is_point_in_polygon(bell.to_local(event.position), bell.polygon)
		if bell_clicked:
			bell_click_count += 1
		if !bell_activated && bell_click_count >= 5:
			bell_activated = true
			game_stats.max_lives = 6
			game_stats.current_lives = game_stats.max_lives
			game_stats.total_time = 180
			game_stats.time_remaining = game_stats.total_time
			audio_stream_player.play()
