@tool
class_name EditorGizmos
extends Object

signal redraw_requested

var _gizmos: Array[EditorGizmo] = []
var _target: Node
var _undo_redo: EditorUndoRedoManager


func _init(undo_redo: EditorUndoRedoManager, target: Node) -> void:
	_undo_redo = undo_redo
	_target = target

	_target.call(EditorGizmoPlugin.GIZMO_METHOD_NAME, self)


func _input(viewport: Control, event: InputEvent) -> bool:
	for gizmo in _gizmos:
		if gizmo._do_input(viewport, event):
			return true

	return false


func _draw(viewport: Control) -> void:
	for gizmo in _gizmos:
		gizmo._do_draw(viewport)


func is_empty() -> bool:
	return _gizmos.is_empty()


func translate_2d(property: StringName, on_move: Callable = Callable()) -> EditorGizmo:
	var position: Vector2 = _target.get(property)
	var g := EditorTranslate2Gizmo.new(_target, _undo_redo, property)
	g.changed.connect(redraw_requested.emit)
	_gizmos.push_back(g)

	if on_move.is_valid():
		g.moved.connect(on_move)

	return g
