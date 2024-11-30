extends HBoxContainer
class_name HeartContainer

const HEART_SCENE = preload("res://GUI/heart.tscn")

@export var game_stats: GameStats

@onready var erase_timer: Timer = $EraseTimer

func _ready() -> void:
	max_hearts = game_stats.max_lives
	update_hearts(game_stats.current_lives, false)
	game_stats.lives_updated.connect(_on_lives_updated)

var max_hearts := 0: set = set_max_hearts
func set_max_hearts(value: int) -> void:
	max_hearts = value
	for i in range(max_hearts):
		var heart := HEART_SCENE.instantiate()
		add_child(heart)

func _on_lives_updated(current_hearts: int) -> void:
	update_hearts(current_hearts)

func update_hearts(current_hearts: int, wait: bool = false) -> void:
	if wait:
		erase_timer.start()
		await erase_timer.timeout
	var children := get_children()
	var hearts: Array[Heart]
	for i in range(children.size()):
		var heart := children[i] as Heart
		if is_instance_valid(heart):
			heart.erased = false
			hearts.append(heart)
	var hearts_to_erase := clampi(max_hearts - current_hearts, 0, max_hearts)
	for i in range(hearts_to_erase):
		if i % 2 == 0:
			hearts.pop_front().erased = true
		else:
			hearts.pop_back().erased = true
