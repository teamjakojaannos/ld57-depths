@tool
class_name EditorGizmos
extends RefCounted

var _created_gizmos: Array[EditorGizmoHandle] = []
var _is_creating_gizmos := false


func translate_2d(position: Vector2) -> EditorGizmoHandle:
	print("yay?")
	if not _is_creating_gizmos:
		push_error("Gizmos can only be created during [_create_2d_gizmos]")
		return

	print("????")
	var g := EditorGizmoHandle.new(position)
	_created_gizmos.push_back(g)
	print("what")
	return g


func _create_gizmos_with(node: Node) -> Array[EditorGizmoHandle]:
	print("start")
	_created_gizmos = []

	_is_creating_gizmos = true
	node.call(EditorAnimatedSpriteImporterPlugin.GIZMO_METHOD_NAME, self)
	_is_creating_gizmos = false

	var result = _created_gizmos.duplicate()
	_created_gizmos.clear()
	print("Created %s gizmos" % result.size())
	return result
