@tool
extends Area2D
class_name BubbleElevator

@export var enabled: bool = true:
	get:
		return enabled
	set(value):
		enabled = value
		_refresh.call_deferred()

func _refresh() -> void:
	if !enabled:
		process_mode = Node.PROCESS_MODE_DISABLED
		$Bubbles.emitting = false
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
		$Bubbles.emitting = true

# For easily disabling via signals hooked in-editor.
func disable() -> void:
	enabled = false
