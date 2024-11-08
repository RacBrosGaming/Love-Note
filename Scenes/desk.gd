extends Node2D

signal desk_selected()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material

func _on_area_2d_mouse_entered() -> void:
	shader.set_shader_parameter("enabled", true)

func _on_area_2d_mouse_exited() -> void:
	shader.set_shader_parameter("enabled", false)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.is_released():
		desk_selected.emit()
