extends Panel

@onready var sprite_2d: Sprite2D = $Sprite2D

var erased:= false: set = set_erased
func set_erased(value: bool) -> void:
	erased = value
	if erased:
		sprite_2d.frame = 5
	else:
		sprite_2d.frame = 1
