extends Node2D
class_name Note

var starting_position: Vector2
var grid_data: GridData
var directions := {
	"right": Vector2i.RIGHT,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"up": Vector2i.UP,
}
var selected_desk: Desk
var last_position: Vector2
var nearby_desks: Dictionary#[String, Vector2i]
var moving := false

@onready var ray_cast_2d: RayCast2D = $RayCast2D

func with_data(p_starting_position: Vector2, p_grid_data: GridData) -> Note:
	starting_position = p_starting_position
	grid_data = p_grid_data
	return self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = starting_position

func _unhandled_input(event: InputEvent) -> void:
	for direction: String in directions.keys():
		if event.is_action_pressed(direction):
			if nearby_desks.has(direction):
				var desk: Desk = nearby_desks[direction]
				select_desk(desk)
	if event.is_action_pressed("select"):
		move()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if !moving && !last_position.is_equal_approx(position):
		ray_cast_2d.enabled = true
		check_neaby_desks()
		last_position = position
		ray_cast_2d.enabled = false

func move() -> void:
	if !moving && is_instance_valid(selected_desk):
		var tween := create_tween()
		tween.tween_property(self, "position", selected_desk.position, 1)
		moving = true
		reset_nearby_desks()
		await tween.finished
		moving = false

func check_neaby_desks() -> void:
	reset_nearby_desks()
	for direction: String in directions.keys():
		var direction_vector: Vector2i = directions[direction]
		var desk := get_nearby_desk(direction_vector)
		if is_instance_valid(desk):
			nearby_desks[direction] = desk
			desk.desk_selected.connect(_on_desk_selected)
			desk.desk_hovered.connect(_on_desk_hovered)
			desk.active = true

func get_nearby_desk(direction: Vector2i) -> Desk:
	var desk: Desk
	ray_cast_2d.target_position = direction * grid_data.grid_spacing
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
	nearby_desks.clear()
	selected_desk = null

func select_desk(desk: Desk) -> void:
	if is_instance_valid(desk):
		if is_instance_valid(selected_desk):
			selected_desk.hovered = false
		selected_desk = desk
		selected_desk.hovered = true

func _on_desk_hovered(desk: Desk) -> void:
	select_desk(desk)

func _on_desk_selected(desk: Desk) -> void:
	select_desk(desk)
	move()
