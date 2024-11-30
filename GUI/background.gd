extends TextureRect

@export var game_stats: GameStats
@onready var game_time: Label = $GameTime

func _ready() -> void:
	game_stats.time_updated.connect(_on_time_updated)
	update_game_time(game_stats.time_remaining)

func _on_time_updated(time_remaining: float) -> void:
	update_game_time(time_remaining)

func update_game_time(time_remaining: float) -> void:
	var total_seconds := int(time_remaining)
	var seconds := total_seconds % 60
	@warning_ignore("integer_division")
	var minutes := total_seconds / 60
	game_time.text = ("%02d:%02d" % [minutes, seconds])
	if game_stats.time_remaining <= 30:
		game_time.add_theme_color_override("font_color", Color.RED)
	elif game_stats.time_remaining <= 60:
		game_time.add_theme_color_override("font_color", Color.ORANGE)
	else:
		game_time.add_theme_color_override("font_color", Color.WHITE)
