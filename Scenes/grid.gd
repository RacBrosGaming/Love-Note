@tool
extends Node2D
class_name Grid

signal setup_grid

@export var desk_count := Vector2i(6, 3)
@export var desk_size := Vector2i(96, 80)
var walking_area := desk_count * 2
var walking_tile_size := desk_size / 2

const NOTE_SCENE = preload("res://Scenes/note.tscn")
const DESK_SCENE = preload("res://Scenes/desk.tscn")
const DESK_BULLY_SCENE = preload("res://Scenes/desk_bully.tscn")
const EMPTY_DESK_SCENE = preload("res://Scenes/empty_desk.tscn")

@onready var desk_scenes := [
	DESK_SCENE,
	EMPTY_DESK_SCENE
]

@onready var desks: TileMapLayerScene = $Desks
@onready var a_star_debug: TileMapLayer = $AStarDebug
@onready var walkable_grid: TileMapLayer = $WalkableGrid

var a_star_grid: AStarGrid2D
var npc_a_star_grid: AStarGrid2D
var note: Note
var start_position: Vector2i
var start_desk: Desk
var end_position: Vector2i
var end_desk: Desk
var max_empty_desks := 3
var current_empty_desks := 0

func _ready() -> void:
	setup_grids()
	spawn_desks()
	if not Engine.is_editor_hint():
		spawn_note()
		spawn_note_destination()
		while find_goal_path().is_empty():
			reroll_empty_desks()
		add_builly_desk()
		end_desk = desks.get_cell_scene(end_position) as Desk
		if is_instance_valid(end_desk):
			end_desk.is_end = true
		start_desk = desks.get_cell_scene(start_position) as Desk
		if is_instance_valid(start_desk):
			start_desk.is_start = true
		randomize_students()
		#debug_npc_path()
		setup_grid.emit()

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

func find_npc_path(start: Vector2, end: Vector2i) -> Array[Vector2]:
	walkable_grid.clear()
	var global_path: Array[Vector2]
	var starting_cell := convert_position_to_cell(start)
	if npc_a_star_grid.is_in_bounds(starting_cell.x, starting_cell.y):
		if npc_a_star_grid.is_in_bounds(end.x, end.y):
			var path := npc_a_star_grid.get_id_path(starting_cell, end)
			for cell in path:
				walkable_grid.set_cell(cell, 0, Vector2.RIGHT)
				var global_cell_position := convert_cell_to_position(cell)
				global_path.append(global_cell_position)
	else:
		var top_right := Vector2(npc_a_star_grid.region.size.x - 1, 1)
		walkable_grid.set_cell(top_right, 0, Vector2.RIGHT)
		var top_right_global_position := convert_cell_to_position(top_right)
		global_path.append(top_right_global_position)
	return global_path

func convert_position_to_cell(target_position: Vector2) -> Vector2i:
	return walkable_grid.local_to_map(walkable_grid.to_local(target_position))

func convert_cell_to_position(target_cell: Vector2i) -> Vector2:
	return walkable_grid.to_global(walkable_grid.map_to_local(target_cell))

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
	var column := 0
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
		var column := desk_count.x - 1
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

func add_builly_desk() -> void:
	var desk_cells: Array[Vector2i]
	for i in desk_count.x:
		for j in desk_count.y:
			var cell := Vector2i(i, j)
			var tile := desks.get_cell_scene(cell)
			if tile is Desk:
				desk_cells.append(cell)
	desk_cells.erase(end_position)
	desk_cells.erase(start_position)
	var desk_cell := desk_cells[randi_range(0, desk_cells.size() - 1)]
	add_desk_to_grid(DESK_BULLY_SCENE, desk_cell)

func add_desk_to_grid(desk_scene: PackedScene, desk_position: Vector2i) -> void:
	var desk := desk_scene.instantiate() as Node2D
	desks.set_cell_scene(desk_position, desk)
	a_star_grid.set_point_solid(desk_position, desk_scene == EMPTY_DESK_SCENE)
	npc_a_star_grid.set_point_solid(desk_position * 2, true)

func get_random_desk() -> PackedScene:
	var i: int = randi_range(0, desk_scenes.size() - 1)
	var desk: PackedScene
	desk = desk_scenes[i]
	if desk == EMPTY_DESK_SCENE:
		current_empty_desks += 1
	if current_empty_desks > max_empty_desks:
		desk = DESK_SCENE
	return desk

func randomize_students() -> void:
	var desk_cells: Array[Vector2i]
	for i in desk_count.x:
		for j in desk_count.y:
			var cell := Vector2i(i, j)
			var tile := desks.get_cell_scene(cell)
			if tile is Desk && !tile is DeskBully:
				desk_cells.append(cell)
	desk_cells.erase(end_position)
	desk_cells.erase(start_position)
	
	for i in range(desk_cells.size()):
		var tile := desks.get_cell_scene(desk_cells[i])
		var desk := tile as Desk
		var kid_choice := i
		if kid_choice >= desk.kids.size():
			kid_choice -= desk.kids.size()
		desk.current_sprite = desk.kids[kid_choice]
