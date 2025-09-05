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
		for child in self.get_children():
			# FIXME: base class for tasks
			if child is not KillEveryFishTask:
				continue

			track_task(child)


func track_task(task: Node) -> void:
	_tasks_remaining += 1
	task.complete.connect(_complete_task)

func _complete_task() -> void:
	_tasks_remaining -= 1

	if _tasks_remaining <= 0:
		complete.emit()

func allow_completion() -> void:
	for task in get_children():
		# FIXME: base class for tasks
		if task is KillEveryFishTask:
			task.can_complete = true
