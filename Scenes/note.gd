extends Area2D
class_name Note

var starting_position: Vector2
var grid_data: GridData
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
var moving := false

@onready var ray_cast_2d: RayCast2D = $RayCast2D

func with_data(p_starting_position: Vector2, p_grid_data: GridData) -> Note:
	starting_position = p_starting_position
	grid_data = p_grid_data
	return self

func _ready() -> void:
	position = starting_position

func _unhandled_input(event: InputEvent) -> void:
	for direction: String in directions.keys():
		if !moving && event.is_action_pressed(direction):
			var direction_vector: Vector2i = directions[direction]
			if nearby_desks.has(direction_vector):
				current_direction = direction_vector
				var desk: Desk = nearby_desks[direction_vector]
				hover_desk(desk)
	if event.is_action_pressed("select"):
		move()

func _physics_process(_delta: float) -> void:
	if !moving && !last_position.is_equal_approx(position):
		ray_cast_2d.enabled = true
		check_neaby_desks()
		current_desk = get_nearby_desk(Vector2i.ZERO)
		current_direction = Vector2i.ZERO
		if is_instance_valid(current_desk):
			current_desk.direction = current_direction
		last_position = position
		ray_cast_2d.enabled = false

func move() -> void:
	if !moving && is_instance_valid(hovered_desk):
		var tween := create_tween()
		tween.tween_property(self, "position", hovered_desk.position, 1)
		moving = true
		current_desk = hovered_desk
		await tween.finished
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
			desk.active = true
			desk.direction = -direction_vector

func get_nearby_desk(direction: Vector2i) -> Desk:
	var desk: Desk
	ray_cast_2d.target_position = direction * grid_data.grid_spacing
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
	if !moving:
		hover_desk(desk)

func _on_desk_selected(desk: Desk) -> void:
	hover_desk(desk)
	move()
