extends Node
class_name Task

signal complete

var can_complete: bool = true:
	get:
		return can_complete
	set(value):
		can_complete = value
		_check_completed.call_deferred()

var _completion_handled: bool = false


func _is_completed() -> bool:
	return false


func _check_completed() -> void:
	if _completion_handled or !can_complete:
		return

	if _is_completed():
		_completion_handled = true
		complete.emit()
