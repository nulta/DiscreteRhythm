extends Camera2D
class_name CameraV


const BASE_PUNCH_STRENGTH = 20

@export var focus_node: CanvasItem = null

var _punch_tween: Tween = null


func _process(_delta: float) -> void:
	if is_instance_valid(focus_node) and "position" in focus_node:
		position = focus_node.position
		if "size" in focus_node:
			position += focus_node.size / 2


func punch_to(dir: Vector2 = Vector2.UP, time: float = 0.3, strength: float = 1.0) -> void:
	offset = dir * (BASE_PUNCH_STRENGTH * strength)

	if is_instance_valid(_punch_tween):
		_punch_tween.kill()

	_punch_tween = create_tween().set_trans(Tween.TRANS_QUINT)
	_punch_tween.tween_property(self, "offset", Vector2.ZERO, time)
