@tool
extends Node2D
class_name Grid

@export var desk_count := Vector2i(6, 3)
@export var desk_size := Vector2i(96, 80)
var walking_area := desk_count * 2
var walking_tile_size := desk_size / 2

const NOTE_SCENE = preload("res://Scenes/note.tscn")
const DESK_SCENE = preload("res://Scenes/desk.tscn")
const EMPTY_DESK_SCENE = preload("res://Scenes/empty_desk.tscn")

@onready var desks: TileMapLayerScene = $Desks
@onready var a_star_debug: TileMapLayer = $AStarDebug
@onready var walkable_grid: TileMapLayer = $WalkableGrid

var a_star_grid: AStarGrid2D
var npc_a_star_grid: AStarGrid2D
var note: Note
var start_position: Vector2i
var end_position: Vector2i

func _ready() -> void:
	setup_grids()
	spawn_desks()
	if not Engine.is_editor_hint():
		spawn_note()
		spawn_note_destination()
		while find_goal_path().is_empty():
			reroll_empty_desks()
		var desk := desks.get_cell_scene(end_position) as Desk
		if is_instance_valid(desk):
			desk.goal = true
		#debug_npc_path()

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
	setup_npc_grid()

func setup_npc_grid() -> void:
	walkable_grid.clear()
	walkable_grid.tile_set.tile_size = walking_tile_size
	walkable_grid.position = walking_tile_size / 2
	npc_a_star_grid = AStarGrid2D.new()
	npc_a_star_grid.region = Rect2i(Vector2i.ZERO, walking_area)
	npc_a_star_grid.offset = walking_tile_size / 2
	npc_a_star_grid.cell_size = walking_tile_size
	npc_a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	npc_a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	npc_a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	npc_a_star_grid.jumping_enabled = false
	npc_a_star_grid.update()

func find_goal_path() -> Array[Vector2i]:
	a_star_debug.clear()
	var path := a_star_grid.get_id_path(start_position, end_position)
	for cell in path:
		a_star_debug.set_cell(cell, 0, Vector2.ZERO)
	return path

func find_npc_path(start: Vector2i, end: Vector2i) -> Array[Vector2]:
	walkable_grid.clear()
	var global_path: Array[Vector2]
	var starting_cell := walkable_grid.local_to_map(walkable_grid.to_local(start))
	if npc_a_star_grid.is_in_bounds(starting_cell.x, starting_cell.y):
		var path := npc_a_star_grid.get_id_path(walkable_grid.local_to_map(walkable_grid.to_local(start)), end)
		for cell in path:
			walkable_grid.set_cell(cell, 0, Vector2.RIGHT)
			var global_cell_position := walkable_grid.to_global(walkable_grid.map_to_local(cell))
			global_path.append(global_cell_position)
	else:
		var top_right := Vector2(npc_a_star_grid.region.size.x - 1, 1)
		walkable_grid.set_cell(top_right, 0, Vector2.RIGHT)
		var top_right_global_position := walkable_grid.to_global(walkable_grid.map_to_local(top_right))
		global_path.append(top_right_global_position)
	return global_path

func debug_npc_path() -> void:
	for column in npc_a_star_grid.region.size.x:
		for row in npc_a_star_grid.region.size.y:
			var cell := Vector2i(column, row)
			if !npc_a_star_grid.is_point_solid(cell):
				walkable_grid.set_cell(cell, 0, Vector2.ZERO)

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
	var furthest_distance: float
	
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
	var desk := desk_scene.instantiate() as Node2D
	desks.set_cell_scene(desk_position, desk)
	a_star_grid.set_point_solid(desk_position, desk_scene != DESK_SCENE)
	npc_a_star_grid.set_point_solid(desk_position * 2, true)

func get_random_desk() -> PackedScene:
	var rand: int = randi_range(0, 2)
	var desk: PackedScene
	if rand > 0:
		desk = DESK_SCENE
	else:
		desk = EMPTY_DESK_SCENE
	return desk
