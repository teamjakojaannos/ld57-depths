extends Node
class_name Components

static func try_connect(node: Node, component_name: String, signal_name: String, fn: Callable) -> void:
	var component = find(node, component_name)
	if component is Node:
		if not component.is_connected(signal_name, fn):
			component.connect(signal_name, fn)

static func try_connect_to(component: Node, signal_name: String, fn: Callable) -> void:
	if component is Node:
		if not component.is_connected(signal_name, fn):
			component.connect(signal_name, fn)

static func set_default_sibling(node: Node, property: String, component_name: String) -> void:
	var existing = node.get("property")
	if match_by_class_name(existing, component_name):
		return
	
	var component = find(node.get_parent(), component_name)
	if component != null:
		node.set(property, component)

static func set_default(node: Node, property: String, component: Node) -> void:
	var existing = node.get("property")
	if existing == null and component is Node:
		node.set(property, component)	

static func find(node: Node, clazz: String) -> Variant:
	var by_name = node.get_node_or_null(clazz)
	if match_by_class_name(by_name, clazz):
		return by_name
	
	for child in node.get_children():
		if match_by_class_name(child, clazz):
			return child

	return null

static func match_by_class_name(node: Node, clazz: String) -> bool:
	var script = node.get_script()
	if script is Script:
		# FIXME: does not support inheritance
		return script.get_global_name() == clazz

	# Fallback to matching by built-in class
	return node.is_class(clazz)
