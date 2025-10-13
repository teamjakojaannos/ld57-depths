@tool
class_name EditorGizmos
extends RefCounted

var _created_gizmos: Array[EditorGizmo] = []
var _is_creating_gizmos := false


func translate_2d(position: Vector2, on_move: Callable) -> EditorGizmo:
	if not _is_creating_gizmos:
		push_error("Gizmos can only be created during [_create_2d_gizmos]")
		return

	var g := EditorTranslate2Gizmo.new(position)
	g.moved.connect(on_move)
	_created_gizmos.push_back(g)
	return g


func _create_gizmos_for(node: Node) -> Array[EditorGizmo]:
	if _is_creating_gizmos:
		push_error("Multiple overlapping calls to _create_gizmos_for(): await is not allowed during gizmo creation!")
		return []

	_created_gizmos = []

	_is_creating_gizmos = true
	node.call(EditorAnimatedSpriteImporterPlugin.GIZMO_METHOD_NAME, self)
	_is_creating_gizmos = false

	var result = _created_gizmos
	_created_gizmos = []
	return result
