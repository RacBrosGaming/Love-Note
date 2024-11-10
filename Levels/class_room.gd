extends Node2D

@onready var grid: Node2D = $Grid

var note_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i: int in grid.desks.size():
		for j: int in grid.desks[i].size():
			grid.desks[i][j].desk_selected.connect(_on_desk_selected.bind([i, j]))

func _on_desk_selected(extra_args: Array) -> void:
	var column: int = extra_args[0]
	var row: int = extra_args[1]
	note_position = grid.grid_to_pixel(column, row)
	grid.note.position = note_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
