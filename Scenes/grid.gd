@tool
extends Node2D

@export var grid_data: GridData

const DESK_SCENE := preload("res://Scenes/desk.tscn")
const NOTE_SCENE = preload("res://Scenes/note.tscn")

var desks: Array[Array] = []
var note: Note

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		desks = setup_grid()
		spawn_desks()
		spawn_note()

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
			#var rand: int = randi_range(0, 0)
			#var desk = possible_desks[rand].instance()
			var desk := DESK_SCENE.instantiate() as Node2D
			add_child(desk)
			desk.position = grid_to_pixel(i, j)
			desks[i][j] = desk;

func spawn_note() -> void:
	var column := randi_range(0, grid_data.grid_size.x - 1)
	var row := randi_range(0, grid_data.grid_size.y - 1)
	note = NOTE_SCENE.instantiate() as Note
	note.with_data(grid_to_pixel(column, row), grid_data)
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
