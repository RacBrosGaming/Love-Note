extends HBoxContainer
class_name HeartContainer

const HEART_SCENE = preload("res://GUI/heart.tscn")

@onready var erase_timer: Timer = $EraseTimer

var max_hearts := 0: set = set_max_hearts
func set_max_hearts(value: int) -> void:
	max_hearts = value
	for i in range(max_hearts):
		var heart := HEART_SCENE.instantiate()
		add_child(heart)

func update_hearts(current_hearts: int) -> void:
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
