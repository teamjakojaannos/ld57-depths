class_name Nodes


## Finds a node with a matching [code]class_name[/code] (or a built-in
## class). Nodes are searched from direct siblings of [param node].
static func find_by_class(node: Node, clazz: String) -> Variant:
	if node == null:
		return null

	if match_by_class_name(node, clazz):
		return node

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
