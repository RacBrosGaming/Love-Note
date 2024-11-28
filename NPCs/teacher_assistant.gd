extends Node2D
class_name TeacherAssistant

signal note_found(note: Note)
signal stopped_moving
signal arrived_at_note

const SPEED = 50.0

@export var grid: Grid

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_timer: Timer = $WalkTimer
@onready var eyes: Eyes = $Eyes

var walk_path: Array[Vector2]
var target_position := Vector2(-1, -1)
var current_direction := Vector2.ZERO
var moving := false: set = set_moving
func set_moving(value: bool) -> void:
	moving = value
	if moving == false:
		stopped_moving.emit()

var note: Note
var found_note := false: set = set_found_note
func set_found_note(value: bool) -> void:
	if found_note == true:
		walk_timer.start()
	found_note = value

var walked_to_note := false: set = set_walked_to_note
func set_walked_to_note(value: bool) -> void:
	walked_to_note = value
	if walked_to_note == true:
		arrived_at_note.emit()

func _ready() -> void:
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	eyes.note_found.connect(_on_eyes_note_found)

func _process(_delta: float) -> void:
	if !is_instance_valid(note):
		found_note = false
		walked_to_note = false
	var animation := "idle"
	if !global_position.is_equal_approx(target_position) && !target_position.is_equal_approx(Vector2(-1, -1)):
		animation = "walk"
	if found_note && global_position.is_equal_approx(target_position):
		var direction := global_position.direction_to(note.global_position)
		var cross := Vector2.UP.cross(direction)
		if cross >= 0:
			current_direction = Vector2.RIGHT
		else:
			current_direction = Vector2.LEFT
		animation = "found_note"
	match current_direction:
		Vector2.LEFT:
			animated_sprite_2d.play(animation + "_left")
		Vector2.RIGHT:
			animated_sprite_2d.play(animation + "_right")
		Vector2.UP:
			animated_sprite_2d.play(animation + "_up")
		Vector2.DOWN, _:
			animated_sprite_2d.play(animation + "_down")


func _physics_process(_delta: float) -> void:
	if found_note:
		move_without_pause()
	else:
		move()

func move_without_pause() -> void:
	walk_timer.paused = true
	moving = true
	global_position = global_position.move_toward(target_position, 1)

	if global_position.is_equal_approx(target_position):
		walk_path.pop_front()
		if !walk_path.is_empty():
			var new_direction := global_position.direction_to(walk_path[0])
			current_direction = new_direction
			target_position = walk_path[0]
	if walk_path.is_empty():
		moving = false
		walk_timer.paused = false
		walked_to_note = true

func move() -> void:
	if walk_path.is_empty():
		walk_path = get_walk_path()
		if walk_path.size() > 1:
			walk_path.pop_front()
		if !walk_path.is_empty():
			current_direction = global_position.direction_to(walk_path[0])
		return
	
	if target_position.is_equal_approx(Vector2(-1, -1)):
		return

	if moving == false:
		return

	global_position = global_position.move_toward(target_position, 1)

	if global_position.is_equal_approx(target_position):
		walk_path.pop_front()
		if !walk_path.is_empty():
			var new_direction := global_position.direction_to(walk_path[0])
			if current_direction.is_equal_approx(new_direction) || found_note:
				target_position = walk_path[0]
			else:
				moving = false
				walk_timer.start()
			current_direction = new_direction
		else:
			moving = false
			walk_timer.start()

func get_walk_path(target_cell := Vector2i(-1, -1)) -> Array[Vector2]:
	if target_cell == Vector2i(-1, -1):
		var column := randi_range(0, grid.walking_area.x - 2)
		var row := randi_range(0, grid.walking_area.y - 2)
		target_cell = Vector2i(column, row)
	var path := grid.find_npc_path(global_position, target_cell)
	return path

func _on_walk_timer_timeout() -> void:
	if moving == false && !walk_path.is_empty():
		target_position = walk_path[0]
		moving = true

func _on_eyes_note_found(p_note: Note) -> void:
	note_found.emit(p_note)
	discover_note(p_note)

func discover_note(p_note: Note) -> void:
	note = p_note
	if is_instance_valid(note):
		if note.moving == true:
			await note.stopped_moving
		move_to_position(note.global_position)
		found_note = true

func move_to_position(goal_position: Vector2) -> void:
	var target_cell := grid.convert_position_to_cell(goal_position)
	var left_of_position := Vector2i(target_cell.x - 1, target_cell.y)
	var right_of_position := Vector2i(target_cell.x + 1, target_cell.y)
	var left_path := get_walk_path(left_of_position)
	var right_path := get_walk_path(right_of_position)
	var left_size := left_path.size()
	var right_size := right_path.size()
	if !left_path.is_empty() && left_size < right_size:
		walk_path = left_path
	else:
		walk_path = right_path
	moving = true
	print(found_note, walk_path)
