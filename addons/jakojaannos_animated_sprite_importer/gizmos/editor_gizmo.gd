@tool
# FIXME: gdscript-formatter#133: reorder command drops @abstract
# @abstract
class_name EditorGizmo
extends RefCounted

var _render_root: Control = null


static func _to_viewport_coords(position: Vector2) -> Vector2:
	var editor_scene_root := EditorInterface.get_editor_viewport_2d()
	var to_viewport = editor_scene_root.get_final_transform()
	return to_viewport * position


# @abstract
func _draw() -> void:
	printerr("TODO: gdscript-formatter issue #133")


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
