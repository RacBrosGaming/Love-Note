extends Area2D
class_name TeacherAssistant

signal note_found(note: Note)

const SPEED = 50.0

@export var grid: Grid

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_timer: Timer = $WalkTimer
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var vision_cone: Sprite2D = $VisionCone

var walk_path: Array[Vector2]
var moving := false
var target_position := Vector2(-1, -1)
var current_direction := Vector2.ZERO

var look_for_note := false
var found_note := false
var last_note_position := Vector2.ZERO
var note: Note

var vision_cone_default := Color(0.17, 0.17, 0.17, 0.5)
var vision_cone_warning := Color(1, 0.54902, 0, 0.5)
var vision_cone_found := Color(0.862745, 0.0784314, 0.235294, 0.5)

func _ready() -> void:
	walk_timer.timeout.connect(_on_walk_timer_timeout)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	vision_cone.modulate = vision_cone_default

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
	move()
	check_for_note()

func move() -> void:
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

func check_for_note() -> void:
	if look_for_note && is_instance_valid(note):
		last_note_position = note.global_position
		found_note = note_visible(note.global_position)
		if found_note:
			vision_cone.modulate = vision_cone_found
			note_found.emit(note)
			look_for_note = false

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

func _on_area_entered(area: Area2D) -> void:
	if area is Note:
		note = area
		look_for_note = true
		ray_cast_2d.enabled = true
		vision_cone.modulate = vision_cone_warning

func _on_area_exited(area: Area2D) -> void:
	if area is Note:
		note = null
		look_for_note = false
		ray_cast_2d.enabled = false
		vision_cone.modulate = vision_cone_default

func note_visible(note_position: Vector2) -> bool:
	var collider: Note
	ray_cast_2d.target_position = note_position - ray_cast_2d.global_position
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		collider = ray_cast_2d.get_collider() as Note
	return is_instance_valid(collider)
