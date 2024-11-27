@tool
extends Area2D
class_name Eyes

signal note_found(note: Note)

@export var vision_cone_default := Color(0.17, 0.17, 0.17, 0.5)
@export var vision_cone_warning := Color(1, 0.54902, 0, 0.5)
@export var vision_cone_found := Color(0.862745, 0.0784314, 0.235294, 0.5)
@export var vision_cone_sprite := preload("res://Assets/Components/vision_cone.png")

@onready var vision_cone_sprite_2d: Sprite2D = $VisionConeSprite
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var note: Note
var look_for_note := false
var found_note := false
var last_note_position := Vector2.ZERO

func _ready() -> void:
	vision_cone_sprite_2d.texture = vision_cone_sprite
	vision_cone_sprite_2d.modulate = vision_cone_default
	area_entered.connect(_on_eyes_entered)
	area_exited.connect(_on_eyes_exited)

func _on_eyes_entered(area: Area2D) -> void:
	if area is Note:
		note = area
		look_for_note = true
		ray_cast_2d.enabled = true
		vision_cone_sprite_2d.modulate = vision_cone_warning

func _on_eyes_exited(area: Area2D) -> void:
	if area is Note:
		note = null
		look_for_note = false
		ray_cast_2d.enabled = false
		vision_cone_sprite_2d.modulate = vision_cone_default

func note_visible(note_position: Vector2) -> bool:
	var collider: Note
	ray_cast_2d.target_position = note_position - ray_cast_2d.global_position
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		collider = ray_cast_2d.get_collider() as Note
	return is_instance_valid(collider)

func _process(_delta: float) -> void:
	if look_for_note && is_instance_valid(note):
		last_note_position = note.global_position
		found_note = note_visible(note.global_position)
		if found_note:
			vision_cone_sprite_2d.modulate = vision_cone_found
			note_found.emit(note)
			look_for_note = false
