extends Desk
class_name DeskBully

signal call_teacher(target_position: Vector2)

@onready var pause_timer: Timer = $PauseTimer

func _ready() -> void:
	super._ready()
	pause_timer.timeout.connect(_on_pause_timer_timeout)

func set_has_note(value: bool) -> void:
	has_note = value
	if has_note:
		taunt()
		note.paused = true
		await note.stopped_moving
		note.visible_to_teacher = true
		pause_timer.start()
		call_teacher.emit(note.global_position)

func taunt() -> void:
	animation_player.play("taunt")

func set_direction(value: Vector2i) -> void:
	direction = value
	if direction == Vector2i.ZERO:
		if !has_note:
			play_idle()
	else:
		animation_player.stop()
	sprite_2d.frame = kid_direction[direction]

func _on_pause_timer_timeout() -> void:
	if is_instance_valid(note):
		note.visible_to_teacher = false
		play_idle()
		note.paused = false
