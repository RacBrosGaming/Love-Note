extends Desk
class_name DeskBully

signal call_teacher(target_position: Vector2)

func set_has_note(value: bool) -> void:
	has_note = value
	if has_note:
		animation_player.play("taunt")
		call_teacher.emit(note.global_position)

func set_direction(value: Vector2i) -> void:
	direction = value
	if direction == Vector2i.ZERO:
		if !has_note:
			play_idle()
	else:
		animation_player.stop()
		sprite_2d.frame = kid_direction[direction]
