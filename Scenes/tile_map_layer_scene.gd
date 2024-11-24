extends TileMapLayer
class_name TileMapLayerScene

var scenes: Dictionary = {} #[Vector2i, Node2D]

func _enter_tree() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)

func _on_child_entered_tree(node: Node) -> void:
	await node.ready
	var node_2d := node as Node2D
	if is_instance_valid(node_2d):
		var cell := local_to_map(to_local(node_2d.global_position))
		set_cell_scene(cell, node_2d)

func _on_child_exiting_tree(node: Node) -> void:
	scenes.erase(node.get_meta("cell"))

func get_cell_scene(cell: Vector2i) -> Node2D:
	return scenes.get(cell)

func set_cell_scene(cell: Vector2i, node: Node2D) -> void:
	scenes[cell] = node
	node.set_meta("cell", cell)
