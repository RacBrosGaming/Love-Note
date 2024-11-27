extends Desk
class_name DeskBully

signal call_teacher(target_position: Vector2)

@onready var pause_timer: Timer = $PauseTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	pause_timer.timeout.connect(_on_pause_timer_timeout)

func set_has_note(value: bool) -> void:
	has_note = value
	if has_note:
		animation_player.play("taunt")
		note.paused = true
		pause_timer.start()
		monitorable = false
		collision_shape_2d.disabled = true
		call_teacher.emit(note.global_position)

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
		monitorable = true
		collision_shape_2d.disabled = false
		play_idle()
		note.paused = false
