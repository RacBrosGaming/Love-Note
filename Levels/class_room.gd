extends Node2D

@onready var teacher: Teacher = $Teacher
@onready var grid_position: Marker2D = $GridPosition

const GRID = preload("res://Scenes/grid.tscn")

var grid_transform: Transform2D

#@onready var grid: Node2D = $Grid
#
#var note_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#teacher.note_found.connect(_on_note_found)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_note_found(_note: Note) -> void:
	if is_instance_valid(grid_position):
		var children := grid_position.get_children()
		for child in children:
			child.queue_free()
		var grid := GRID.instantiate()
		grid_position.add_child(grid)
