extends Node2D
class_name TeacherAssistant

const SPEED = 50.0

@export var grid: Grid

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_timer: Timer = $WalkTimer

var walk_path: Array[Vector2]
var moving := false
var target_position := Vector2(-1, -1)
var current_direction := Vector2.ZERO

func _ready() -> void:
	walk_timer.timeout.connect(_on_walk_timer_timeout)

func _process(_delta: float) -> void:
	var animation := "idle"
	if !global_position.is_equal_approx(target_position) && !target_position.is_equal_approx(Vector2(-1, -1)):
		animation = "walk"
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
	if walk_path.is_empty():
		get_random_walk_path()
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
			if current_direction.is_equal_approx(new_direction):
				target_position = walk_path[0]
			else:
				current_direction = new_direction
				moving = false
				walk_timer.start()
		else:
			moving = false
			walk_timer.start()

func get_random_walk_path() -> void:
	var column := randi_range(0, grid.walking_area.x - 2)
	var row := randi_range(0, grid.walking_area.y - 2)
	var target_cell := Vector2i(column, row)
	var path := grid.find_npc_path(global_position, target_cell)
	walk_path = path

func _on_walk_timer_timeout() -> void:
	if moving == false:
		target_position = walk_path[0]
		moving = true
