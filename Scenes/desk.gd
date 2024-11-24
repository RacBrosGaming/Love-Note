extends Area2D
class_name Desk

signal desk_selected(desk: Desk)
signal desk_hovered(desk: Desk)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var empty_desk: Array[Texture2D] = []
@export var kids: Array[Texture2D] = []

const KID_IDLE_FRAME := 0
const KID_LEFT_FRAME := 2
const KID_RIGHT_FRAME := 3
const KID_UP_FRAME := 4
const KID_DOWN_FRAME := 5
const KID_FRAMES := 6
const KID_DIRECTION := {
	Vector2i.ZERO: KID_IDLE_FRAME,
	Vector2i.LEFT: KID_LEFT_FRAME,
	Vector2i.RIGHT: KID_RIGHT_FRAME,
	Vector2i.UP: KID_UP_FRAME,
	Vector2i.DOWN: KID_DOWN_FRAME,
}

var active: bool: set = set_active
var hovered: bool: set = set_hover
var direction: Vector2i: set = set_direction
var pending_hover := false

func set_active(value: bool) -> void:
	active = value
	highlight(active)

func set_hover(value: bool) -> void:
	hovered = value
	super_highlight(hovered)

func set_direction(value: Vector2i) -> void:
	direction = value
	if direction == Vector2i.ZERO:
		play_idle()
	else:
		animation_player.stop()
	sprite_2d.frame = KID_DIRECTION[direction]

func _ready() -> void:
	if !kids.is_empty():
		sprite_2d.texture = kids[randi_range(0, kids.size() - 1)]
		sprite_2d.hframes = KID_FRAMES
	#if !empty_desk.is_empty():
		#sprite_2d.texture = empty_desk[randi_range(0, empty_desk.size() - 1)]
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
	animation_player.play("idle", -1, randf_range(0.5, 1.5))

func highlight(enabled: bool) -> void:
	shader.set_shader_parameter("enabled", enabled)

func super_highlight(enabled: bool) -> void:
	if enabled:
		shader.set_shader_parameter("color", Color.HOT_PINK)
	else:
		shader.set_shader_parameter("color", Color.WHITE)
