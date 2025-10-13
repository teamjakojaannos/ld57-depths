@tool
class_name EditorAnimatedSpriteImporterPlugin
extends EditorPlugin

const EDITOR_2D_VIEWPORT_CLASS_NAME := "CanvasItemEditorViewport"
const GIZMO_METHOD_NAME := "_create_2d_gizmos"

var inspector_plugin: EditorInspectorPlugin
var _last_node: Node = null
var _node_gizmos: Array[EditorGizmo] = []
var _is_dragging: bool:
	get:
		return !!_dragged_gizmo
var _dragged_gizmo: EditorTranslate2Gizmo = null


func _enter_tree() -> void:
	_cleanup_gizmos()

	inspector_plugin = EditorAnimatedSpriteImporterInspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	_cleanup_gizmos()

	if inspector_plugin != null:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null


func _cleanup_gizmos() -> void:
	_node_gizmos = []
	_last_node = null


func _create_gizmos_for_node(node: Node) -> Array[EditorGizmo]:
	var gizmos := EditorGizmos.new()
	return gizmos._create_gizmos_for(node)


func _edit(object: Object) -> void:
	if object == _last_node:
		return

	_cleanup_gizmos()
	update_overlays()
	var node = object as Node
	if not node:
		return

	_node_gizmos = _create_gizmos_for_node(node)
	if _node_gizmos.is_empty():
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


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if _node_gizmos.is_empty():
		return

	var editor_scene_root := EditorInterface.get_editor_viewport_2d()

	# Transform from scene coordinates to viewport coordinates
	var m = editor_scene_root.get_final_transform()

	for gizmo in _node_gizmos:
		gizmo._do_draw(viewport_control)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _node_gizmos.is_empty():
		return false

	var viewport_control := _find_canvas_item_editor_viewport()
	var mouse = viewport_control.get_local_mouse_position()

	var editor_scene_root := EditorInterface.get_editor_viewport_2d()

	# Transforms for converting coordinates to/from scene coordinates
	var to_viewport = editor_scene_root.get_final_transform()
	var to_scene = editor_scene_root.get_final_transform().affine_inverse()

	if event is InputEventMouseMotion:
		if _is_dragging:
			var translate_gizmo := _dragged_gizmo as EditorTranslate2Gizmo
			if translate_gizmo:
				var scene_mouse_pos = to_scene * mouse
				translate_gizmo.moved.emit(scene_mouse_pos)
				update_overlays()
			return true

	var button = event as InputEventMouseButton
	if button and button.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if button.is_released():
			_dragged_gizmo = null
		elif button.is_pressed():
			for gizmo in _node_gizmos:
				var translate_gizmo := gizmo as EditorTranslate2Gizmo
				if not translate_gizmo:
					continue

				var viewport_pos = to_viewport * translate_gizmo.position

				var is_hovering: bool = viewport_pos.distance_to(mouse) < 100.0
				if is_hovering:
					_dragged_gizmo = gizmo
					return true

	return false


func _handles(object: Object) -> bool:
	# FIXME: validate return type
	if object.has_method(GIZMO_METHOD_NAME):
		return true

	return false
