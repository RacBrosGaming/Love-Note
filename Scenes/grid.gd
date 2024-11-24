@tool
extends Node2D

@export var desk_count := Vector2i(6, 3)
@export var desk_size := Vector2i(96, 80)

const NOTE_SCENE = preload("res://Scenes/note.tscn")
const DESK_SCENE = preload("res://Scenes/desk.tscn")
const EMPTY_DESK_SCENE = preload("res://Scenes/empty_desk.tscn")

@onready var desks: TileMapLayerScene = $Desks
@onready var a_star_debug: TileMapLayer = $AStarDebug

var a_star_grid: AStarGrid2D
var note: Note
var start_position: Vector2i
var end_position: Vector2i

func _ready() -> void:
	setup_grids()
	spawn_desks()
	if not Engine.is_editor_hint():
		spawn_note()
		spawn_note_destination()
		while find_path().is_empty():
			print("callled")
			reroll_empty_desks()
	var desk := desks.get_cell_scene(end_position) as Desk
	if is_instance_valid(desk):
		desk.goal = true

func setup_grids() -> void:
	desks.clear()
	desks.tile_set.tile_size = desk_size
	a_star_debug.clear()
	a_star_debug.tile_set.tile_size = desk_size
	a_star_grid = AStarGrid2D.new()
	a_star_grid.region = Rect2i(Vector2i.ZERO, desk_count)
	a_star_grid.cell_size = desks.tile_set.tile_size
	a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star_grid.jumping_enabled = false
	a_star_grid.update()

func find_path() -> Array[Vector2i]:
	var path := a_star_grid.get_id_path(start_position, end_position)
	for cell in path:
		a_star_debug.set_cell(cell, 0, Vector2.ZERO)
	return path

func spawn_desks() -> void:
	for i in desk_count.x:
		for j in desk_count.y:
			add_desk_to_grid(get_random_desk(), Vector2i(i, j))

func spawn_note() -> void:
	var column := randi_range(0, desk_count.x - 1)
	var row := randi_range(0, desk_count.y - 1)
	var spawn_position := Vector2i(column, row)
	note = NOTE_SCENE.instantiate() as Note
	note.with_data(desks.map_to_local(spawn_position), desk_size)
	start_position = spawn_position
	add_desk_to_grid(DESK_SCENE, start_position)
	add_child(note)

func spawn_note_destination() -> void:
	var furthest_spawn: Vector2i
	var furthest_distance: int
	
	for i in range(0, 10):
		var column := randi_range(0, desk_count.x - 1)
		var row := randi_range(0, desk_count.y - 1)
		var spawn_position := Vector2i(column, row)
		var distance_to_spawn := start_position.distance_to(spawn_position)
		if distance_to_spawn > furthest_distance:
			furthest_spawn = spawn_position
			furthest_distance = distance_to_spawn
	
	end_position = furthest_spawn
	add_desk_to_grid(DESK_SCENE, end_position)

func reroll_empty_desks() -> void:
	var empty_cells: Array[Vector2i]
	for i in desk_count.x:
		for j in desk_count.y:
			var cell := Vector2i(i, j)
			var tile := desks.get_cell_scene(cell)
			if tile is EmptyDesk:
				empty_cells.append(cell)
	for empty_cell in empty_cells:
		add_desk_to_grid(get_random_desk(), empty_cell)

func add_desk_to_grid(desk_scene: PackedScene, desk_position: Vector2i) -> void:
	var desk := desk_scene.instantiate()
	desks.set_cell_scene(desk_position, desk)
	a_star_grid.set_point_solid(desk_position, desk_scene != DESK_SCENE)

func get_random_desk() -> PackedScene:
	var rand: int = randi_range(0, 2)
	var desk: PackedScene
	if rand > 0:
		desk = DESK_SCENE
	else:
		desk = EMPTY_DESK_SCENE
	return desk
