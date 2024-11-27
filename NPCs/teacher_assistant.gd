extends Node2D
class_name TeacherAssistant

const SPEED = 50.0

@export var grid: Grid

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_timer: Timer = $WalkTimer
@onready var eyes: Eyes = $Eyes

var walk_path: Array[Vector2]
var moving := false
var target_position := Vector2(-1, -1)
var current_direction := Vector2.ZERO

var found_note := false
var note: Note

func _ready() -> void:
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	eyes.note_found.connect(_on_eyes_note_found)

func _process(_delta: float) -> void:
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
	move()

func move() -> void:
	if walk_path.is_empty():
		if !found_note:
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
	note = p_note
	found_note = true
	await note.stopped_moving
	var target_cell := grid.convert_position_to_cell(note.global_position)
	var left_of_note := Vector2i(target_cell.x - 1, target_cell.y)
	var right_of_note := Vector2i(target_cell.x + 1, target_cell.y)
	var left_path := get_walk_path(left_of_note)
	var right_path := get_walk_path(right_of_note)
	var left_size := left_path.size()
	var right_size := right_path.size()
	if left_size < right_size:
		walk_path = left_path
	else:
		walk_path = right_path
	moving = true
