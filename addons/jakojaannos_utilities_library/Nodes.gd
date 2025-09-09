@tool
class_name Nodes

const GROUP_SAFE_TO_DELETE_IN_EDITOR: String = \
	"I KNOW WHAT I AM DOING THIS NODE IS SAFE TO AUTOMATICALLY FREE IN-EDITOR"

## Finds a node with a matching [code]class_name[/code] (or a built-in
## class). Nodes are searched from direct siblings of [param node].[br]
## [br]
## If [param node] is of matching class and [param match_self] is set to
## [code]true[/code], the [param node] itself is returned.
static func find_by_class(node: Node, clazz: String, match_self: bool = true) -> Variant:
	if is_null(node):
		return null

	if match_self and match_by_class_name(node, clazz):
		return node

	var by_name = node.get_node_or_null(clazz)
	if match_by_class_name(by_name, clazz):
		return by_name

	for child in node.get_children():
		if match_by_class_name(child, clazz):
			return child

	return null


static func match_by_class_name(node: Node, clazz: String) -> bool:
	if is_null(node):
		return false

	var script = node.get_script()
	if script is Script:
		# FIXME: does not support inheritance
		return script.get_global_name() == clazz

	# Fallback to matching by built-in class
	return node.is_class(clazz)

## @tool-safe null check, resilient to non-tool script instances evaluating to
## Object#null -abominations, which seemingly, in some cases, pass the regular
## `node != null` -checks.[br]
## [br]
## Prefer this over regular null checks in tool-scripts.
static func is_null(node: Node) -> bool:
	return node is not Node

## Marks the node as "safe to free in-editor". This is useful for any case when
## short-lived nodes are spawned in tool scripts for preview purposes.[br]
## [br]
## Beware that [Lifetime]-components of safe-to-free nodes are executed and
## [b]will[/b] call [code]queue_free[/code] on their parent nodes in-editor.
static func mark_as_safe_to_free(node: Node) -> void:
	if is_null(node):
		return

	node.add_to_group(GROUP_SAFE_TO_DELETE_IN_EDITOR)

## Checks if the node is marked as "safe to free in-editor". May evaluate to
## [code]true[/code] only for nodes which have explicitly been marked as safe
## (via [member Nodes.mark_as_safe_to_free]).
static func is_safe_to_free_in_editor(node: Node) -> bool:
	if is_null(node):
		return false

	# Never free edited scene root
	if Engine.is_editor_hint():
		var edited_scene = EditorInterface.get_edited_scene_root()
		if edited_scene == node:
			return false

		return node.is_in_group(GROUP_SAFE_TO_DELETE_IN_EDITOR)

	return true
