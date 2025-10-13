@tool
class_name EditorAnimatedSpriteImporterPlugin
extends EditorPlugin

const EDITOR_2D_VIEWPORT_CLASS_NAME := "CanvasItemEditorViewport"
const GIZMO_METHOD_NAME := "_create_2d_gizmos"

var inspector_plugin: EditorInspectorPlugin
var _last_node: Node = null
var _gizmos: EditorGizmos = null


func _enter_tree() -> void:
	_cleanup_gizmos()

	inspector_plugin = EditorAnimatedSpriteImporterInspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	_cleanup_gizmos()

	if inspector_plugin != null:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null


func _create_gizmos(target: Node) -> void:
	_gizmos = EditorGizmos.new(get_undo_redo(), target)
	Signals.try_connect(_gizmos.redraw_requested, update_overlays)


func _cleanup_gizmos() -> void:
	_last_node = null
	if _gizmos:
		Signals.try_disconnect(_gizmos.redraw_requested, update_overlays)
		_gizmos = null


func _edit(object: Object) -> void:
	if object == _last_node:
		return

	_cleanup_gizmos()
	update_overlays()
	var node = object as Node
	if not node:
		return

	_create_gizmos(node)
	if _gizmos.is_empty():
		return

	_last_node = node


## Finds the [CanvasItemEditorViewport] for the 2D editor. This is the same
## [Control] that gets passed into [method _forward_canvas_draw_over_viewport].
func _find_canvas_item_editor_viewport() -> Control:
	# The parent of the currently edited scene, a [SubViewport]
	var editor_scene_root := EditorInterface.get_editor_viewport_2d()
	# ...[SubViewport] is contained within a [SubViewportContainer]
	var wrapper = editor_scene_root.get_parent()
	# ...which is contained within the actual common ancestor.
	var parent = wrapper.get_parent()

	return Nodes.find_by_class_name(parent, EDITOR_2D_VIEWPORT_CLASS_NAME, true, true)


func _forward_canvas_draw_over_viewport(viewport: Control) -> void:
	if not _gizmos or _gizmos.is_empty():
		return

	_gizmos._draw(viewport)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not _gizmos or _gizmos.is_empty():
		return false

	var viewport = _find_canvas_item_editor_viewport()
	if _gizmos._input(viewport, event):
		return true

	return false


func _handles(object: Object) -> bool:
	# FIXME: validate return type
	if object.has_method(GIZMO_METHOD_NAME):
		return true

	return false
