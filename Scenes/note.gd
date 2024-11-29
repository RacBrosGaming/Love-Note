extends Area2D
class_name Note

signal stopped_moving
signal reached_goal

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var love_letter: LoveLetter = $CanvasLayer/LoveLetter

var starting_position: Vector2
var desk_size: Vector2i
var directions := {
	"right": Vector2i.RIGHT,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"up": Vector2i.UP,
}
var current_direction := Vector2i.ZERO
var current_desk: Desk
var hovered_desk: Desk
var last_position := Vector2(-1, -1)
var nearby_desks: Dictionary#[Vector2i, Desk]
var moving := false: set = set_moving
var visible_to_teacher := false: set = set_visible_to_teacher
var paused := false
var found := false
var start_reached := false
var end_reached := false

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func set_moving(value: bool) -> void:
	moving = value
	if moving == false:
		set_visible_to_teacher(false)
		stopped_moving.emit()
	else:
		set_visible_to_teacher(true)

func set_visible_to_teacher(value: bool) -> void:
	visible_to_teacher = value
	if visible_to_teacher == false:
		monitorable = false
		collision_shape_2d.disabled = true
	else:
		monitorable = true
		collision_shape_2d.disabled = false

func with_data(p_starting_position: Vector2, p_desk_size: Vector2i) -> Note:
	starting_position = p_starting_position
	desk_size = p_desk_size
	return self

func _ready() -> void:
	visible = false
	paused = true
	set_visible_to_teacher(false)
	position = starting_position
	love_letter.write(global_position)
	await  love_letter.finished_writing
	visible = true
	paused = false

func _unhandled_input(event: InputEvent) -> void:
	for direction: String in directions.keys():
		if !found && !paused && !moving && event.is_action_pressed(direction):
			var direction_vector: Vector2i = directions[direction]
			if nearby_desks.has(direction_vector):
				current_direction = direction_vector
				var desk: Desk = nearby_desks[direction_vector]
				hover_desk(desk)
	if event.is_action_pressed("select"):
		move()

func _process(_delta: float) -> void:
	var facing_position := Vector2.ZERO
	match current_direction:
		Vector2i.LEFT:
			facing_position = Vector2(-32, 0)
		Vector2i.RIGHT:
			facing_position = Vector2(32, 0)
		Vector2i.UP:
			facing_position = Vector2(0, -32)
		Vector2i.DOWN:
			facing_position = Vector2(0, 32)
		_:
			facing_position = Vector2.ZERO
	sprite_2d.position = facing_position

func _physics_process(_delta: float) -> void:
	if !found && !paused && (!moving && !last_position.is_equal_approx(position)) || nearby_desks.is_empty():
		ray_cast_2d.enabled = true
		check_neaby_desks()
		current_direction = Vector2i.ZERO
		if !is_instance_valid(current_desk):
			current_desk = get_nearby_desk(Vector2i.ZERO)
			current_desk.direction = current_direction
		last_position = position
		ray_cast_2d.enabled = false

func move() -> void:
	if !found && !paused && !moving && is_instance_valid(hovered_desk):
		var tween := create_tween()
		tween.tween_property(self, "global_position", hovered_desk.global_position, 1)
		var sprite_tween := create_tween()
		sprite_tween.tween_property(sprite_2d, "position", Vector2.ZERO, 1)
		moving = true
		if is_instance_valid(current_desk):
			current_desk.note = null
		current_desk = hovered_desk
		await tween.finished
		if is_instance_valid(current_desk):
			current_desk.note = self
		reset_nearby_desks()
		moving = false

func check_neaby_desks() -> void:
	reset_nearby_desks()
	for direction: String in directions.keys():
		var direction_vector: Vector2i = directions[direction]
		var desk := get_nearby_desk(direction_vector)
		if is_instance_valid(desk):
			nearby_desks[direction_vector] = desk
			desk.desk_selected.connect(_on_desk_selected)
			desk.desk_hovered.connect(_on_desk_hovered)
			desk.start_reached.connect(_on_start_reached)
			desk.end_reached.connect(_on_end_reached)
			desk.active = true
			desk.direction = -direction_vector

func get_nearby_desk(direction: Vector2i) -> Desk:
	var desk: Desk
	ray_cast_2d.target_position = direction * desk_size
	ray_cast_2d.hit_from_inside = direction == Vector2i.ZERO
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		desk = ray_cast_2d.get_collider() as Desk
	return desk

func reset_nearby_desks() -> void:
	for desk: Desk in nearby_desks.values():
		desk.active = false
		desk.desk_selected.disconnect(_on_desk_selected)
		desk.desk_hovered.disconnect(_on_desk_hovered)
		desk.start_reached.disconnect(_on_start_reached)
		desk.end_reached.disconnect(_on_end_reached)
		desk.hovered = false
		desk.direction = Vector2i.ZERO
	nearby_desks.clear()
	hovered_desk = null

func hover_desk(desk: Desk) -> void:
	if is_instance_valid(desk):
		current_direction = find_nearby_desk(desk)
		if is_instance_valid(hovered_desk):
			hovered_desk.hovered = false
		if is_instance_valid(current_desk):
			current_desk.direction = current_direction
		hovered_desk = desk
		hovered_desk.hovered = true

func find_nearby_desk(desk: Desk) -> Vector2i:
	var found_desk: Vector2i = nearby_desks.find_key(desk)
	return found_desk

func _on_desk_hovered(desk: Desk) -> void:
	if !found && !paused && !moving:
		hover_desk(desk)

func _on_desk_selected(desk: Desk) -> void:
	if !found && !paused && !moving:
		hover_desk(desk)
		move()

func _on_start_reached() -> void:
	if end_reached:
		start_reached = true
		reached_goal.emit()
		paused = true

func _on_end_reached() -> void:
	end_reached = true
