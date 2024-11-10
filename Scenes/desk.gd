extends Area2D
class_name Desk

signal desk_selected(desk: Desk)
signal desk_hovered(desk: Desk)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shader: ShaderMaterial = sprite_2d.material

var active: bool: set = set_active
var hovered: bool: set = set_hover
var pending_hover := false

func set_active(value: bool) -> void:
	active = value
	highlight(active)

func set_hover(value: bool) -> void:
	hovered = value
	super_highlight(hovered)

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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

func highlight(enabled: bool) -> void:
	shader.set_shader_parameter("enabled", enabled)

func super_highlight(enabled: bool) -> void:
	if enabled:
		shader.set_shader_parameter("color", Color.HOT_PINK)
	else:
		shader.set_shader_parameter("color", Color.WHITE)
