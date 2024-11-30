extends Node
class_name GameTimer

signal timeout()

@export var game_stats: GameStats

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = game_stats.total_time
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	game_stats.time_remaining = timer.time_left

func start() -> void:
	timer.start()

func pause(paused: bool) -> void:
	timer.paused = paused

func _on_timer_timeout() -> void:
	timeout.emit()
