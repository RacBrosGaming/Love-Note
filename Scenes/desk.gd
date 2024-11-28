extends Area2D
class_name Desk

signal desk_selected(desk: Desk)
signal desk_hovered(desk: Desk)
signal reached_goal

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var kids: Array[Texture2D] = []
@export var goal_sprite: Texture2D

@export var  kid_idle_frame := 0
@export var  kid_left_frame := 2
@export var  kid_right_frame := 3
@export var  kid_up_frame := 4
@export var  kid_down_frame := 5
@export var  kid_frames := 6

@onready var kid_direction := {
	Vector2i.ZERO: kid_idle_frame,
	Vector2i.LEFT: kid_left_frame,
	Vector2i.RIGHT: kid_right_frame,
	Vector2i.UP: kid_up_frame,
	Vector2i.DOWN: kid_down_frame,
}

var has_note: bool: set = set_has_note
var note: Note: set = set_note
var active: bool: set = set_active
var hovered: bool: set = set_hover
var direction: Vector2i: set = set_direction
var pending_hover := false
var goal: bool: set = set_goal

func set_note(value: Note) -> void:
	note = value
	set_has_note(is_instance_valid(note))

func set_has_note(value: bool) -> void:
	has_note = value
	if has_note && goal:
		reached_goal.emit()

func set_active(value: bool) -> void:
	active = value
	highlight(active)

func set_hover(value: bool) -> void:
	hovered = value
	super_highlight(hovered)

func set_goal(value: bool) -> void:
	goal = value
	if goal && goal_sprite:
		sprite_2d.texture = goal_sprite

func set_direction(value: Vector2i) -> void:
	direction = value
	if direction == Vector2i.ZERO:
		play_idle()
	else:
		animation_player.stop()
	sprite_2d.frame = kid_direction[direction]

func _ready() -> void:
	if !kids.is_empty():
		sprite_2d.texture = kids[randi_range(0, kids.size() - 1)]
		sprite_2d.hframes = kid_frames
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	play_idle()

func _process(_delta: float) -> void:
	if pending_hover && active:
		desk_hovered.emit(self)
		pending_hover = false
	#if goal:
		#reached_goal.emit()
		#has_note = false

func _on_mouse_entered() -> void:
	desk_hovered.emit(self)
	pending_hover = !active

func _on_mouse_exited() -> void:
	pending_hover = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch) && event.is_released():
		desk_selected.emit(self)

func play_idle() -> void:
	animation_player.play("idle", -1, randf_range(0.5, 1.5))

func highlight(enabled: bool) -> void:
	shader.set_shader_parameter("enabled", enabled)

func super_highlight(enabled: bool) -> void:
	if enabled:
		shader.set_shader_parameter("color", Color.HOT_PINK)
	else:
		shader.set_shader_parameter("color", Color.WHITE)
