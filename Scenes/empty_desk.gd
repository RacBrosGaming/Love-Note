extends Node2D
class_name EmptyDesk

@export var desks: Array[Texture2D] = []
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if !desks.is_empty():
		sprite_2d.texture = desks[randi_range(0, desks.size() - 1)]
