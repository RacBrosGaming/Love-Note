extends Control
class_name GameTimer

signal timeout()

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $TimerLabel

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	update_seconds()
	update_color()

func update_seconds() -> void:
	var total_seconds := int(timer.time_left)
	var seconds := total_seconds % 60
	@warning_ignore("integer_division")
	var minutes := total_seconds / 60
	timer_label.text = ("%02d:%02d" % [minutes, seconds])

func update_color() -> void:
	if timer.time_left <= 30:
		timer_label.add_theme_color_override("font_color", Color.RED)
	elif timer.time_left <= 60:
		timer_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

func start() -> void:
	timer.start()

func pause(paused: bool) -> void:
	timer.paused = paused

func _on_timer_timeout() -> void:
	timeout.emit()
