extends CharacterBody2D
class_name Teacher

signal note_found(note: Note)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_timer: Timer = $MoveTimer
@onready var turn_around_timer: Timer = $TurnAroundTimer
@onready var look_timer: Timer = $LookTimer
@onready var eyes: Eyes = $Eyes

var direction := Vector2.RIGHT
var lerp_direction := direction
var moving := false
var facing_desks := false
var looking_right := false
var turn_smoothing := 5.0

var note: Note

var found_note:= false: set = set_found_note
func set_found_note(value: bool) -> void:
	found_note = value

func _ready() -> void:
	move_timer.timeout.connect(_on_move_timer_timeout)
	look_timer.timeout.connect(_on_look_timer_timeout)
	turn_around_timer.timeout.connect(_on_turn_around_timer_timeout)
	turn_around_timer.start(randf_range(2.0, 5.0))
	animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	eyes.rotate(PI)
	eyes.note_found.connect(_on_eyes_note_found)

func _process(_delta: float) -> void:
	if !is_instance_valid(note):
		found_note = false
	animated_sprite_2d.flip_h = direction == Vector2.LEFT
	if found_note:
		if animated_sprite_2d.animation != "discover_letter":
			animated_sprite_2d.play("discover_letter")
	else:
		if looking_right:
			animated_sprite_2d.play("look_right")
		elif moving:
			animated_sprite_2d.play("walk_right")
		else:
			if animated_sprite_2d.animation != "look_up" && animated_sprite_2d.animation != "idle":
				animated_sprite_2d.play("look_up")

func _physics_process(delta: float) -> void:
	if found_note:
		return

	if moving:
		var collider := move_and_collide(direction)
		if is_instance_valid(collider):
			direction = -direction
	var from := eyes.rotation
	var to := 0.0
	var weight := turn_smoothing * delta
	if facing_desks:
		if lerp_direction == Vector2.RIGHT:
			eyes.rotation = clockwise_lerp_angle(from, to, weight)
		else:
			eyes.rotation = counter_clockwise_lerp_angle(from, to, weight)
	elif looking_right:
		var right := (3 * PI) / 2
		var left := PI / 2
		if lerp_direction == Vector2.RIGHT:
			eyes.rotation = clockwise_lerp_angle(from, right, weight)
		else:
			eyes.rotation = counter_clockwise_lerp_angle(from, left, weight)
	else:
		to = PI
		if direction == Vector2.LEFT:
			eyes.rotation = clockwise_lerp_angle(from, to, weight)
		else:
			eyes.rotation = counter_clockwise_lerp_angle(from, to, weight)

func counter_clockwise_lerp_angle(from: float, to: float, weight: float) -> float:
	var distance := fposmod(to - from, -TAU)
	return from + distance * weight

func clockwise_lerp_angle(from: float, to: float, weight: float) -> float:
	var distance := fposmod(to - from, TAU)
	return from + distance * weight

func _on_move_timer_timeout() -> void:
	moving = false
	facing_desks = false
	turn_around_timer.start(randf_range(2.0, 5.0))

func _on_look_timer_timeout() -> void:
	looking_right = false
	facing_desks = true
	moving = true
	move_timer.start(randf_range(2.0, 5.0))

func _on_turn_around_timer_timeout() -> void:
	looking_right = true
	look_timer.start(randf_range(1.0, 2.0))
	if randi_range(0, 1) == 0:
		direction = -direction
	lerp_direction = direction

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "look_up":
		animated_sprite_2d.play("idle")

func _on_eyes_note_found(p_note: Note) -> void:
	note = p_note
	note_found.emit(note)
	found_note = true
	animated_sprite_2d.play("discover_letter")
