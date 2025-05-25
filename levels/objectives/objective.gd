extends Node
class_name Objective

signal complete

var _tasks_remaining: int = 0

func track_task(task: Node) -> void:
	_tasks_remaining += 1
	task.complete.connect(_complete_task)

func _complete_task() -> void:
	_tasks_remaining -= 1

	if _tasks_remaining <= 0:
		complete.emit()
