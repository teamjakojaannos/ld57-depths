@tool
class_name EditorGizmoHandle
extends RefCounted

const ID_NULL := 0

static var _id_counter: int = ID_NULL

var position: Vector2
var _id: int


func _init(position: Vector2) -> void:
	_id_counter += 1
	_id = _id_counter
	self.position = position


func is_valid() -> bool:
	return _id != ID_NULL
