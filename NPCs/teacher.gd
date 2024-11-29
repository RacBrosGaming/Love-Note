extends CharacterBody2D
class_name Teacher

signal note_found(note: Note)
signal arrived_at_note

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_timer: Timer = $MoveTimer
@onready var wait_timer: Timer = $WaitTimer
@onready var eyes: Eyes = $Eyes

var direction := Vector2.RIGHT
var lerp_direction := direction
var moving := false
var facing_desks := false
var looking_right := false
var turn_smoothing := 5.0
var wait_time_min := 2.0
var wait_time_max := 2.5
var move_time_min := 3.0
var move_time_max := 5.0

var note: Note

var found_note:= false: set = set_found_note
func set_found_note(value: bool) -> void:
	found_note = value

var walked_to_note := false: set = set_walked_to_note
func set_walked_to_note(value: bool) -> void:
	walked_to_note = value
	if walked_to_note == true:
		arrived_at_note.emit()

func _ready() -> void:
	move_timer.timeout.connect(_on_move_timer_timeout)
	move_timer.start(randf_range(move_time_min, move_time_max))
	animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	eyes.rotate(PI)
	eyes.note_found.connect(_on_eyes_note_found)

func _process(_delta: float) -> void:
	if !is_instance_valid(note):
		found_note = false
		walked_to_note = false
		wait_timer.paused = false
		move_timer.paused = false
	animated_sprite_2d.flip_h = direction == Vector2.LEFT
	if looking_right && !found_note:
		animated_sprite_2d.play("look_right")
	elif moving:
		animated_sprite_2d.play("walk_right")
	else:
		if animated_sprite_2d.animation != "look_up" && animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("look_up")

func _physics_process(delta: float) -> void:
	if found_note:
		move_without_pause()
	move(delta)

func move_without_pause() -> void:
	var target_position := Vector2(320, global_position.y)
	global_position = global_position.move_toward(target_position, 1)
	if global_position.is_equal_approx(target_position):
		moving = false
		facing_desks = false
		walked_to_note = true

func move(delta: float) -> void:
	if !found_note && moving:
		var collider := move_and_collide(direction)
		if is_instance_valid(collider):
			direction = -direction
	var eye_direction := direction
	if facing_desks:
		eye_direction = Vector2.DOWN
	elif !looking_right:
		eye_direction = Vector2.UP
	rotate_eyes(delta, eye_direction)

func rotate_eyes(delta: float, direction: Vector2) -> void:
	var from := eyes.rotation
	var directions := {
		Vector2.UP: PI,
		Vector2.DOWN: 0.0,
		Vector2.LEFT: PI / 2,
		Vector2.RIGHT: (3 * PI) / 2
	}
	var to := 0.0
	if directions.has(direction):
		to = directions[direction]
	var weight := turn_smoothing * delta
	eyes.rotation = lerp_angle(from, to, weight)

func _on_move_timer_timeout() -> void:
	# face right and away from desks
	moving = false
	facing_desks = false
	looking_right = true
	wait_timer.start(randf_range(wait_time_min, wait_time_max))
	await wait_timer.timeout
	
	# face desks and start walking
	facing_desks = true
	looking_right = false
	moving = true
	wait_timer.start(randf_range(move_time_min, move_time_max))
	await wait_timer.timeout

	# face right and away from desks
	moving = false
	facing_desks = false
	looking_right = true
	wait_timer.start(randf_range(wait_time_min, wait_time_max))
	await wait_timer.timeout
	
	# stop looking right and face chalkboards and setup new direction
	looking_right = false
	facing_desks = false
	if randi_range(0, 1) == 0:
		direction = -direction
	
	# start process all over
	move_timer.start(randf_range(move_time_min, move_time_max))

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "look_up":
		animated_sprite_2d.play("idle")

func _on_eyes_note_found(p_note: Note) -> void:
	note_found.emit(p_note)
	discover_note(p_note)

func discover_note(p_note: Note) -> void:
	note = p_note
	found_note = true
	wait_timer.paused = true
	move_timer.paused = true
	moving = true
	looking_right = false
	facing_desks = true
	var target_position := Vector2(320, global_position.y)
	if !global_position.is_equal_approx(target_position):
		direction = global_position.direction_to(target_position)
