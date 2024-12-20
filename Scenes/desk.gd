extends Area2D
class_name Desk

signal desk_selected(desk: Desk)
signal desk_hovered(desk: Desk)
signal end_reached
signal start_reached

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var kids: Array[Texture2D] = []
@export var start_sprite: Texture2D
@export var end_sprite: Texture2D
@export var answer_sprite :Texture

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

var current_sprite: Texture2D: set = set_current_sprite
var has_note: bool: set = set_has_note
var note: Note: set = set_note
var active: bool: set = set_active
var hovered: bool: set = set_hover
var direction: Vector2i: set = set_direction
var pending_hover := false
var is_start: bool: set = set_start
var is_end: bool: set = set_end

func set_current_sprite(value: Texture2D) -> void:
	current_sprite = value
	sprite_2d.texture = current_sprite
	sprite_2d.hframes = kid_frames

func set_note(value: Note) -> void:
	note = value
	set_has_note(is_instance_valid(note))

func set_has_note(value: bool) -> void:
	has_note = value
	if has_note && is_start:
		start_reached.emit()
	if has_note && is_end:
		end_reached.emit()

func set_active(value: bool) -> void:
	active = value
	highlight(active)

func set_hover(value: bool) -> void:
	hovered = value
	super_highlight(hovered)

func set_end(value: bool) -> void:
	is_end = value
	if is_end && end_sprite:
		sprite_2d.texture = end_sprite

func set_start(value: bool) -> void:
	is_start = value
	if is_start && start_sprite:
		sprite_2d.texture = start_sprite

func set_direction(value: Vector2i) -> void:
	direction = value
	if direction == Vector2i.ZERO:
		play_idle()
	else:
		animation_player.stop()
	sprite_2d.frame = kid_direction[direction]

func _ready() -> void:
	if !kids.is_empty():
		current_sprite = kids[randi_range(0, kids.size() - 1)]
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	play_idle()

func _process(_delta: float) -> void:
	if pending_hover && active:
		desk_hovered.emit(self)
		pending_hover = false

func _on_mouse_entered() -> void:
	desk_hovered.emit(self)
	pending_hover = !active

func _on_mouse_exited() -> void:
	pending_hover = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton || event is InputEventScreenTouch) && event.is_released():
		desk_selected.emit(self)

func play_idle() -> void:
	if !animation_player.current_animation == "answer_wait":
		animation_player.play("idle", -1, randf_range(0.5, 1.5))

func highlight(enabled: bool) -> void:
	shader.set_shader_parameter("enabled", enabled)

func super_highlight(enabled: bool) -> void:
	if enabled:
		shader.set_shader_parameter("color", Color.HOT_PINK)
	else:
		shader.set_shader_parameter("color", Color.WHITE)

func wait_for_results() -> void:
	kid_frames = 5
	current_sprite = answer_sprite
	animation_player.play("answer_wait")

func set_result(answer: bool) -> void:
	if answer:
		animation_player.play("answer_yes")
	else:
		animation_player.play("answer_no")
