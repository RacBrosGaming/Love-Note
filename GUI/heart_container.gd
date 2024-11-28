extends HBoxContainer
class_name HeartContainer

const HEART_SCENE = preload("res://GUI/heart.tscn")

var max_hearts := 0: set = set_max_hearts
func set_max_hearts(value: int) -> void:
	max_hearts = value
	for i in range(max_hearts):
		var heart := HEART_SCENE.instantiate()
		add_child(heart)

func update_hearts(current_hearts: int) -> void:
	var hearts := get_children()
	for i in range(hearts.size()):
		hearts[i].erased = false
	var hearts_to_erase := clampi(max_hearts - current_hearts, 0, max_hearts)
	for i in range(hearts_to_erase):
		if i % 2 == 0:
			hearts.pop_front().erased = true
		else:
			hearts.pop_back().erased = true
