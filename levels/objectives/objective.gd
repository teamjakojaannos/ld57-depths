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

func _allow_completion() -> void:
	for task in get_children():
		# FIXME: base class for tasks
		if task is KillEveryFishTask:
			task.can_complete = true
