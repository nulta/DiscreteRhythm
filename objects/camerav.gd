extends Camera2D
class_name CameraV


const BASE_PUNCH_STRENGTH = 20

@export var focus_node: CanvasItem = null


func _process(_delta: float) -> void:
	if is_instance_valid(focus_node) and "position" in focus_node:
		position = focus_node.position
		if "size" in focus_node:
			position += focus_node.size / 2


func punch_to(dir: Vector2 = Vector2.UP, time: float = 0.4, strength: float = 1.0) -> void:
	var new_offset: = dir * (BASE_PUNCH_STRENGTH * strength)
	var tween: = create_tween().chain().set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "offset", new_offset, time * 2/10.0)
	tween.tween_property(self, "offset", Vector2.ZERO, time * 8/10.0)
