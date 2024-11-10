extends Area2D
class_name Desk

#signal desk_selected()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material

#func _on_mouse_entered() -> void:
	#highlight(true)
#
#func _on_mouse_exited() -> void:
	#highlight(false)
#
#func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event is InputEventMouseButton && event.is_released():
		#desk_selected.emit()

func highlight(enabled: bool) -> void:
	shader.set_shader_parameter("enabled", enabled)

func super_highlight(enabled: bool) -> void:
	if enabled:
		highlight(true)
		shader.set_shader_parameter("color", Color.HOT_PINK)
	else:
		shader.set_shader_parameter("color", Color.WHITE)
