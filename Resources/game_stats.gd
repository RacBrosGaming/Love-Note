extends Resource
class_name GameStats

signal lives_updated(current_lives: int)
signal time_updated(time_remaining: float)

@export var max_lives := 3
@export var total_time := 180.0

var current_lives := max_lives: set = set_current_lives
func set_current_lives(value: int) -> void:
	current_lives = value
	lives_updated.emit(current_lives)

var time_remaining := total_time: set = set_time_remaining
func set_time_remaining(value: float) -> void:
	time_remaining = value
	time_updated.emit(time_remaining)
