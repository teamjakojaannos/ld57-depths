# https://github.com/godotengine/godot/blob/9a5d6d1049e589ce0cac08f65367a084b252c18b/editor/inspector/editor_properties.cpp#L2838
class_name EditorNodePicker
extends EditorProperty
## Ported from C++ to GDScript:

enum Action {
	CLEAR,
	COPY,
	EDIT,
	SELECT,
}

var _assign: Button
var _dropping: bool = false
var _edit: LineEdit
var _editing_node: bool = false
var _menu: MenuButton
var _use_path_from_scene_root: bool = false
var _valid_types: Array[StringName] = []


func _init(
		valid_types: Array[StringName],
		use_path_from_scene_root: bool,
		editing_node: bool,
) -> void:
	_valid_types = valid_types
	_use_path_from_scene_root = use_path_from_scene_root
	_editing_node = editing_node

	var hbc := HBoxContainer.new()
	hbc.add_theme_constant_override("separation", 0)
	add_child(hbc)

	_assign = Button.new()
	_assign.flat = true
	_assign.size_flags_horizontal = SIZE_EXPAND_FILL
	_assign.clip_text = true
	_assign.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_assign.expand_icon = true
	_assign.pressed.connect(_assign_button_pressed)
	_assign.draw.connect(_assign_button_draw)
	_assign.set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)
	hbc.add_child(_assign)

	_menu = MenuButton.new()
	_menu.flat = true
	_menu.about_to_popup.connect(_update_menu)
	hbc.add_child(_menu)

	_menu.get_popup().add_item("Clear", Action.CLEAR)
	_menu.get_popup().add_item("Copy as Text", Action.COPY)
	_menu.get_popup().add_item("Edit", Action.EDIT)
	_menu.get_popup().add_item("Show Node in Tree", Action.SELECT)
	_menu.get_popup().id_pressed.connect(_menu_option_pressed)

	_edit = LineEdit.new()
	_edit.accessibility_name = "Node Path"
	_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_edit.hide()
	_edit.focus_exited.connect(_accept_text)
	_edit.text_submitted.connect(_text_submitted)
	hbc.add_child(_edit)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			_menu.icon = _get_editor_theme_icon("GuiTabMenuHl")
			_menu.get_popup().set_item_icon(Action.CLEAR, _get_editor_theme_icon("Clear"))
			_menu.get_popup().set_item_icon(Action.COPY, _get_editor_theme_icon("ActionCopy"))
			_menu.get_popup().set_item_icon(Action.EDIT, _get_editor_theme_icon("Edit"))
			_menu.get_popup().set_item_icon(Action.SELECT, _get_editor_theme_icon("ExternalLink"))
		NOTIFICATION_DRAG_BEGIN:
			if read_only && _is_drop_valid(get_viewport().gui_get_drag_data()):
				_dropping = true
				_assign.queue_redraw()
		NOTIFICATION_DRAG_END:
			if _dropping:
				_dropping = false
				_assign.queue_redraw()


func _accept_text() -> void:
	_text_submitted(_edit.text)


func _assign_button_draw() -> void:
	if not _dropping:
		return

	var color = get_theme_color("accent_color", "Editor")
	_assign.draw_rect(Rect2(Vector2.ZERO, _assign.size), color, false)


func _assign_button_pressed() -> void:
	var current_value: Node = null

	var property_name := get_edited_property()
	var edited_value := get_edited_object().get(property_name)
	if edited_value is NodePath:
		var base_node = _get_base_node()
		if base_node:
			current_value = base_node.get_node_or_null(edited_value)
	else:
		current_value = edited_value as Node

	EditorInterface.popup_node_selector(
		func(np): _node_selected(np, true),
		_valid_types,
		current_value,
	)


func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
	return not read_only and _is_drop_valid(data as Dictionary)


func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
	var data_dict := data as Dictionary
	var nodes := data_dict["nodes"] as Array

	var node = EditorInterface.get_edited_scene_root().get_node(nodes[0])
	if node:
		_node_selected(node.get_path(), true)


func _get_base_node() -> Node:
	var base_node := get_edited_object() as Node

	if not base_node and get_edited_object().has_meta("__base_node_relative"):
		base_node = get_edited_object().get_meta("__base_node_relative") as Node

	if not base_node:
		base_node = EditorInterface.get_inspector().get_edited_object() as Node

	# TODO: is there way to access `get_editor_selection_history` from GDScript?
	# if (!base_node) {
	# 	// Try a base node within history.
	# 	if (EditorNode::get_singleton()->get_editor_selection_history()->get_path_size() > 0) {
	# 		Object *base = ObjectDB::get_instance(EditorNode::get_singleton()->get_editor_selection_history()->get_path_object(0))
	# 		if (base) {
	# 			base_node = Object::cast_to<Node>(base)
	# 		}
	# 	}
	# }

	if _use_path_from_scene_root:
		if get_edited_object().has_method("get_root_path"):
			base_node = get_edited_object().get_root_path() as Node
		else:
			base_node = EditorInterface.get_edited_scene_root()

	return base_node


func _get_editor_theme_icon(name: StringName) -> Texture2D:
	return get_theme_icon(name, "EditorIcons")


func _get_node_path() -> NodePath:
	var base_node := _get_base_node()
	var property_name := get_edited_property()
	var value := get_edited_object().get(property_name)
	print("%s : %s" % [get_edited_object(), property_name])

	if value is Node:
		var node := value as Node
		if not node.is_inside_tree():
			return NodePath()

		if base_node:
			return base_node.get_path_to(node)
		else:
			return EditorInterface.get_edited_scene_root().get_path_to(node)
	else:
		return value


func _is_drop_valid(drag_data: Dictionary) -> bool:
	if drag_data["type"] != "nodes":
		return false

	var nodes: Array = drag_data["nodes"]
	if nodes.size() != 1:
		return false

	var dropped_node = EditorInterface.get_edited_scene_root().get_node(nodes[0])
	if _valid_types.is_empty():
		return true

	for clazz in _valid_types:
		if Objects.match_by_class_name(dropped_node, clazz):
			return true

	return false


func _menu_option_pressed(pressed_id: int) -> void:
	match pressed_id:
		Action.CLEAR:
			if _editing_node:
				emit_changed(get_edited_property(), null)
			else:
				emit_changed(get_edited_property(), NodePath())
			update_property()
		Action.COPY:
			DisplayServer.clipboard_set(_get_node_path())
		Action.EDIT:
			_assign.hide()
			_menu.hide()

			var node_path: NodePath = _get_node_path()
			_edit.text = node_path
			_edit.show()
			_edit.grab_focus.call_deferred()
		Action.SELECT:
			var edited_node := _get_base_node()
			var node_path := _get_node_path()
			var target_node := edited_node.get_node_or_null(node_path)

			# FIXME: should this be EditorInterface.edit_node(target_node)
			EditorInterface.get_selection().add_node(target_node)


func _node_selected(path: NodePath, absolute: bool) -> void:
	var node_path = path
	var base_node = _get_base_node()
	if not base_node and get_edited_object() is RefCounted:
		var to_node = get_node(path)
		path = EditorInterface.get_edited_scene_root().get_path_to(to_node)

	if absolute and base_node:
		var to_node = get_node(path)
		path = base_node.get_path_to(to_node)

	if _editing_node:
		if not base_node:
			emit_changed(get_edited_property(), EditorInterface.get_edited_scene_root().get_node(path))
		else:
			emit_changed(get_edited_property(), base_node.get_node(path))
	else:
		emit_changed(get_edited_property(), path)

	update_property()


func _set_read_only(read_only: bool) -> void:
	_assign.disabled = read_only
	_menu.disabled = read_only


func _text_submitted(text: String) -> void:
	var node_path: NodePath = text
	_node_selected(node_path, false)
	_edit.hide()
	_assign.show()
	_menu.show()


func _update_menu() -> void:
	print("_update_menu()")
	var node_path := _get_node_path()

	_menu.get_popup().set_item_disabled(Action.CLEAR, node_path.is_empty())
	_menu.get_popup().set_item_disabled(Action.COPY, node_path.is_empty())

	var edited_node := get_edited_object()
	var is_select_enabled: bool = edited_node and edited_node.has_node(node_path)
	_menu.get_popup().set_item_disabled(Action.SELECT, !is_select_enabled)


func _update_property() -> void:
	var base_node := _get_base_node()
	print("_update_property()")
	var path := _get_node_path()
	_assign.tooltip_text = path

	if path.is_empty():
		_assign.icon = null
		_assign.text = "Assign..."
		_assign.flat = false
		return

	_assign.flat = true

	var target_node := base_node.get_node(path)
	if target_node.name.contains("@"):
		_assign.icon = null
		_assign.text = path
		return

	_assign.text = target_node.get_name()
	# FIXME: some way to easily get object icons?
	# assign->set_button_icon(EditorNode::get_singleton()->get_object_icon(target_node, "Node"))
