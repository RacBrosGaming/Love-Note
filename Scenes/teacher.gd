extends CharacterBody2D
class_name Teacher

signal note_found(note: Note)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var eyes: Area2D = $Eyes
@onready var move_timer: Timer = $MoveTimer
@onready var turn_around_timer: Timer = $TurnAroundTimer
@onready var look_timer: Timer = $LookTimer

var look_for_note := false
var found_note := false
var last_note_position := Vector2.ZERO
var direction := Vector2.RIGHT
var lerp_direction := direction
var note: Note
var moving := false
var facing_desks := false
var looking_right := false
var turn_smoothing := 5.0

func _ready() -> void:
	eyes.area_entered.connect(_on_eyes_area_entered)
	eyes.area_exited.connect(_on_eyes_area_exited)
	move_timer.timeout.connect(_on_move_timer_timeout)
	look_timer.timeout.connect(_on_look_timer_timeout)
	turn_around_timer.timeout.connect(_on_turn_around_timer_timeout)
	turn_around_timer.start(randf_range(2.0, 5.0))
	animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	eyes.rotate(PI)

func _process(_delta: float) -> void:
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
		if look_for_note && is_instance_valid(note) && !note.global_position.is_equal_approx(last_note_position):
			last_note_position = note.global_position
			found_note = note_visible(note.global_position)
			if found_note:
				note_found.emit(note)
				look_for_note = false
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

func note_visible(target_position: Vector2) -> bool:
	var collider: Note
	ray_cast_2d.target_position = target_position - ray_cast_2d.global_position
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		collider = ray_cast_2d.get_collider() as Note
	return is_instance_valid(collider)

func _on_eyes_area_entered(area: Area2D) -> void:
	if area is Note:
		note = area
		look_for_note = true
		ray_cast_2d.enabled = true


func _on_eyes_area_exited(area: Area2D) -> void:
	if area is Note:
		note = null
		look_for_note = false
		ray_cast_2d.enabled = false


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
