## Automatically deletes its parent after a delay.
##
## Gives the parent node a fixed lifetime. The parent node will be freed after
## the duration.[br]
## [br]
## [b]Will not free the parent node in-editor, unless parent is explicitly
## marked as safe-to-delete via [member Nodes.mark_as_safe_to_free].[/b] This
## may lead to leaking memory if e.g. in-editor preview instances are not
## properly marked as safe-to-remove.
@tool
extends Node
class_name Lifetime

signal lifetime_ended

@export var duration = 3.0

func _ready() -> void:
	_free_after_delay.call_deferred()

func _free_after_delay() -> void:
	var target = get_parent()
	if Nodes.is_null(target):
		return

	if Engine.is_editor_hint() and not Nodes.is_safe_to_free_in_editor(target):
		return

	await get_tree().create_timer(duration, false).timeout

	lifetime_ended.emit()

	target.queue_free()
