@tool
extends Node2D

@export var grid_data: GridData

const DESK_SCENE := preload("res://Scenes/desk.tscn")
const NOTE_SCENE = preload("res://Scenes/note.tscn")
const EMPTY_DESK = preload("res://Scenes/empty_desk.tscn")

@onready var a_star_debug: TileMapLayer = $AStarDebug

var a_star_grid: AStarGrid2D
var desks: Array[Array] = []
var note: Note
var start_position: Vector2i
var end_position: Vector2i

#manhattan
#diagnal never

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		setup_astar_grid()
		desks = setup_grid()
		spawn_desks()
		spawn_note()
		end_position = grid_data.grid_size - Vector2i(1, 1)
		find_path()

func setup_astar_grid() -> void:
	a_star_grid = AStarGrid2D.new()
	a_star_grid.size = grid_data.grid_size * grid_data.grid_spacing
	a_star_grid.cell_size = grid_data.grid_spacing
	a_star_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star_grid.jumping_enabled = false
	a_star_grid.update()

func find_path() -> void:
	var path := a_star_grid.get_id_path(start_position, end_position)
	for cell in path:
		a_star_debug.set_cell(cell, 1, Vector2.ZERO)

func setup_grid() -> Array[Array]:
	var array: Array[Array] = [];
	for i in grid_data.grid_size.x:
		array.append([])
		for j in grid_data.grid_size.y:
			array[i].append(null)
	return array

func spawn_desks() -> void:
	for i in grid_data.grid_size.x:
		for j in grid_data.grid_size.y:
			var rand: int = randi_range(0, 10)
			#var desk = possible_desks[rand].instance()
			var desk: Node2D
			if rand > 0:
				desk = DESK_SCENE.instantiate()
			else:
				desk = EMPTY_DESK.instantiate()
			add_desk_to_grid(desk, Vector2i(i, j), rand <= 0)

func add_desk_to_grid(desk_scene: Node2D, desk_position: Vector2i, solid: bool) -> void:
	add_child(desk_scene)
	desk_scene.position = grid_to_pixel(desk_position.x, desk_position.y)
	desks[desk_position.x][desk_position.y] = desk_scene
	a_star_grid.set_point_solid(desk_position, solid)

func spawn_note() -> void:
	var column := randi_range(0, grid_data.grid_size.x - 1)
	var row := randi_range(0, grid_data.grid_size.y - 1)
	note = NOTE_SCENE.instantiate() as Note
	note.with_data(grid_to_pixel(column, row), grid_data)
	start_position = Vector2i(column, row)
	add_child(note)

func _draw() -> void:
	if Engine.is_editor_hint():
		var default_font := ThemeDB.fallback_font
		var default_font_size := ThemeDB.fallback_font_size
		for i in grid_data.grid_size.x:
			for j in grid_data.grid_size.y:
				var cell_position := grid_to_pixel(i, j)
				var next_cell_position := grid_to_pixel(i + 1, j + 1)
				var tile_position := cell_position - (grid_data.grid_spacing / 2)
				var tile_size := next_cell_position - cell_position
				draw_rect(Rect2(tile_position, tile_size), Color.GREEN, false, 2.0)
				#draw_rect(Rect2(cell_position, tile_size), Color.LIGHT_GREEN, false, 2.0)
				
				var column_row_string := str(i) + ", " + str(j)
				var string_size := default_font.get_string_size(column_row_string)
				var string_offset := Vector2(cell_position.x - (string_size.x / 2), cell_position.y + (string_size.y / 4))
				draw_string(default_font, string_offset, column_row_string, HORIZONTAL_ALIGNMENT_CENTER, -1, default_font_size)

func grid_to_pixel(column: int, row: int) -> Vector2i:
	var x := grid_data.grid_spacing.x * column
	var y := grid_data.grid_spacing.y * row
	return Vector2i(x, y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
