@tool
extends Task
class_name KillTargetTask

@export var target: Node:
	get:
		return target
	set(value):
		target = value
		update_configuration_warnings()

var _is_target_killed: bool = false:
	get:
		return _is_target_killed
	set(value):
		_is_target_killed = value
		_check_completed.call_deferred()

func _get_configuration_warnings() -> PackedStringArray:
	var health = Nodes.find_by_class(target, Health)
	return PackedStringArray(_validate_target(target, health))

func _ready() -> void:
	can_complete = true

	if Engine.is_editor_hint():
		return

	_subscribe_to_target_death()

static func _validate_target(t: Node, h: Health) -> Array[String]:
	if t == null:
		return ["No target specified for kill task!"]

	if h is not Health:
		return ["Kill task target \"%s\" does not seem to be killable!" % t.name]

	if h.is_dead:
		return ["Kill task target \"%s\" is already dead!" % t.name]

	return []

func _subscribe_to_target_death() -> void:
	var health = Nodes.find_by_class(target, Health)
	var errors = _validate_target(target, health)
	if !errors.is_empty():
		for error in errors:
			push_error(error)
		return

	health.die.connect(
		func():
			_is_target_killed = true
	)

func _is_completed() -> bool:
	return _is_target_killed
