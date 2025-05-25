extends Node

signal complete

@export var kills_required: int = 1

func track_target(target: Node) -> void:
	var health = target.get_node("Health")
	if health is Health:
		health.Die.connect(_record_kill)

func _record_kill() -> void:
	kills_required -= 1

	if kills_required <= 0:
		complete.emit()
