@tool
class_name EditorTranslate2Gizmo
extends EditorGizmo

signal moved(new_pos: Vector2)

var position: Vector2:
	get:
		return get_target_property(_position_property, Vector2.ZERO)
var _position_property: StringName
var _original_pos: Vector2
var _is_dragging: bool = false


func _init(
		target: Node,
		undo_redo: EditorUndoRedoManager,
		property: StringName,
) -> void:
	super._init(target, undo_redo)
	_position_property = property


func _input(event: InputEvent) -> bool:
	var motion := event as InputEventMouseMotion
	if motion:
		if _is_dragging:
			_drag_motion()
			return true

	var button = event as InputEventMouseButton
	if button and button.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if _is_dragging and button.is_released():
			_drag_drop()
			return true
		elif not _is_dragging and button.is_pressed():
			var pos = _to_viewport_coords(position)
			var is_hovering = get_mouse_position_in_viewport().distance_to(pos) < 100.0
			if is_hovering:
				_drag_start()
				return true

	return false


func _draw() -> void:
	draw_circle(position, 5.0, Color.NAVY_BLUE, true)
	draw_circle(position, 100.0, Color.DEEP_SKY_BLUE, false, 2)


func _drag_start() -> void:
	_is_dragging = true
	_original_pos = position


func _drag_motion() -> void:
	var old_position = position
	moved.emit(get_mouse_position_in_scene())

	if old_position != position:
		mark_changed()


func _drag_drop() -> void:
	var final_pos: Vector2 = position
	if _original_pos != final_pos:
		var target = get_target()
		if not target:
			return

		_undo_redo.create_action("Moved translate gizmo for \"%s.%s\" to %s" % [target.name, _position_property, final_pos])
		_undo_redo.add_do_property(target, _position_property, final_pos)
		_undo_redo.add_undo_property(target, _position_property, _original_pos)
		_undo_redo.add_do_method(self, "mark_changed")
		_undo_redo.add_undo_method(self, "mark_changed")
		_undo_redo.commit_action(false)

	_is_dragging = false
	_original_pos = Vector2.ZERO
