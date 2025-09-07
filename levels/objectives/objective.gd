extends Node
class_name Objective

signal complete

var _tasks_remaining: int = 0

## Automatically track all tasks defined as children of this objective node. The
## objective is completed when all of its tasks are completed succesfully.
@export
var auto_track_child_tasks: bool = true

func _ready() -> void:
	if auto_track_child_tasks:
		for child in get_children():
			if child is Task:
				track_task(child)


func track_task(task: Node) -> void:
	_tasks_remaining += 1
	task.complete.connect(_complete_task)

func _complete_task() -> void:
	_tasks_remaining -= 1

	if _tasks_remaining <= 0:
		complete.emit()
