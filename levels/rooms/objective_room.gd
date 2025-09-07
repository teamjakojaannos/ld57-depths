@tool
extends Room
class_name ObjectiveRoom

@export var objective: Objective:
	get:
		return objective
	set(value):
		objective = value
		update_configuration_warnings()

@export var blocker: Node2D

signal objective_completed


func _get_configuration_warnings() -> PackedStringArray:
	var errors = []
	if objective == null:
		errors.push_back("Missing objective!")

	return errors


func setup_room() -> void:
	_on_setup()
	_setup_objective()

func _on_setup() -> void:
	pass

func _setup_objective() -> void:
	if objective == null:
		push_warning("Room \"%s\" has no objective!" % self.name)
		return

	objective.complete.connect(
		func():
			_unblock_exit()
			objective_completed.emit()
	)

func _unblock_exit():
	UI.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
	if blocker != null: blocker.queue_free()
