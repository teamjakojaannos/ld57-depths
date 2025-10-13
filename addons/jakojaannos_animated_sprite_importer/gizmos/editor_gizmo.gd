@tool
# FIXME: gdscript-formatter#133: reorder command drops @abstract
# @abstract
class_name EditorGizmo
extends RefCounted

signal changed

var _render_root: Control = null
var _target: Node
var _undo_redo: EditorUndoRedoManager


static func _to_viewport_coords(position: Vector2) -> Vector2:
	var editor_scene_root := EditorInterface.get_editor_viewport_2d()
	var to_viewport = editor_scene_root.get_final_transform()
	return to_viewport * position


static func _to_scene_coords(position: Vector2) -> Vector2:
	var editor_scene_root := EditorInterface.get_editor_viewport_2d()
	var to_scene = editor_scene_root.get_final_transform().affine_inverse()
	return to_scene * position


func _init(target: Node, undo_redo: EditorUndoRedoManager):
	_target = target
	_undo_redo = undo_redo


func _input(event: InputEvent) -> bool:
	return false


# @abstract
func _draw() -> void:
	printerr("TODO: gdscript-formatter issue #133")


func mark_changed() -> void:
	changed.emit()


func get_mouse_position_in_viewport() -> Vector2:
	return _render_root.get_local_mouse_position()


func get_mouse_position_in_scene() -> Vector2:
	return _to_scene_coords(get_mouse_position_in_viewport())


func draw_circle(
		position: Vector2,
		radius: float,
		color: Color,
		filled: bool = true,
		width: int = -1,
		antialiased: bool = false,
) -> void:
	if not _render_root:
		push_error("draw_* methods can only be called from _draw()!")
		return

	var pos := _to_viewport_coords(position)
	_render_root.draw_circle(pos, radius, color, filled, width, antialiased)


func _do_draw(control: Control) -> void:
	_render_root = control
	_draw()
	_render_root = null


func _do_input(control: Control, event: InputEvent) -> bool:
	_render_root = control
	var result = _input(event)
	_render_root = null

	return result
