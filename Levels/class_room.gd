extends Node2D

@onready var teacher: Teacher = $Teacher
@onready var teacher_assistant: TeacherAssistant = $TeacherAssistant
@onready var grid_position: Marker2D = $GridPosition
@onready var grid: Grid = $GridPosition/Grid
@onready var reset_timer: Timer = $ResetTimer

@onready var heart_container: HeartContainer = $HeartContainer

const GRID = preload("res://Scenes/grid.tscn")

var max_lives := 6
var current_lives := max_lives: set = set_current_lives
func set_current_lives(value: int) -> void:
	current_lives = value
	heart_container.update_hearts(current_lives)

func _ready() -> void:
	teacher.note_found.connect(_on_note_found)
	teacher_assistant.note_found.connect(_on_note_found)
	heart_container.max_hearts = max_lives
	setup()

func setup() -> void:
	connect_bully_to_teacher_assistant()

func connect_bully_to_teacher_assistant() -> void:
	for scene: Node2D in grid.desks.scenes.values():
		if scene is DeskBully:
			var desk_bully := scene as DeskBully
			if is_instance_valid(desk_bully):
				desk_bully.call_teacher.connect(_call_teacher)

func _call_teacher(target_position: Vector2) -> void:
	teacher_assistant.move_to_position(target_position)

func _on_note_found(note: Note) -> void:
	note.found = true
	teacher.discover_note(note)
	teacher_assistant.discover_note(note)
	if !teacher.walked_to_note:
		await teacher.arrived_at_note
	current_lives -= 1
	if !teacher_assistant.walked_to_note:
		await teacher_assistant.arrived_at_note
	reset_timer.start()
	await reset_timer.timeout
	if is_instance_valid(grid_position):
		var children := grid_position.get_children()
		for child in children:
			child.queue_free()
		grid = GRID.instantiate()
		grid_position.add_child(grid)
		teacher_assistant.grid = grid
		setup()
