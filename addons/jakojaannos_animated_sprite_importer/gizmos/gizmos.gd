@tool
class_name EditorGizmos
extends RefCounted

var _created_gizmos: Array[EditorGizmoHandle] = []
var _is_creating_gizmos := false


func translate_2d(position: Vector2) -> EditorGizmoHandle:
	if not _is_creating_gizmos:
		push_error("Gizmos can only be created during [_create_2d_gizmos]")
		return

	var g := EditorGizmoHandle.new(position)
	_created_gizmos.push_back(g)
	return g


func _create_gizmos_with(node: Node) -> Array[EditorGizmoHandle]:
	_created_gizmos = []

	_is_creating_gizmos = true
	node.call(EditorAnimatedSpriteImporterPlugin.GIZMO_METHOD_NAME, self)
	_is_creating_gizmos = false

	var result = _created_gizmos
	_created_gizmos = []
	return result
