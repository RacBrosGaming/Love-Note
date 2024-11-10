@tool
extends Node2D

@export var grid_data: GridData

const DESK_SCENE := preload("res://Scenes/desk.tscn")
const NOTE_SCENE = preload("res://Scenes/note.tscn")

var desks: Array[Array] = []
var note: Note
var note_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	note_position = Vector2i(column, row)
	note = NOTE_SCENE.instantiate()
	note.with_data(grid_to_pixel(column, row), grid_data)
	add_child(note)

#func _draw() -> void:
	#var default_font := ThemeDB.fallback_font
	#var default_font_size := ThemeDB.fallback_font_size
	#for i in grid_size.x:
		#for j in grid_size.y:
			#draw_string(default_font, grid_to_pixel(i, j), str(i) + ", " + str(j), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

func grid_to_pixel(column: int, row: int) -> Vector2i:
	var x := grid_data.grid_offset.x + grid_data.grid_spacing.x * column
	var y := grid_data.grid_offset.y + grid_data.grid_spacing.y * row
	return Vector2i(x, y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
