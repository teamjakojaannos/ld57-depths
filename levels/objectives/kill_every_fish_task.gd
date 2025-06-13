extends Node
class_name KillEveryFishTask

signal complete

@export var room: Room
@export var waves: EnemyWaves

var kills_required: int = 0
var is_completed: bool = false
var can_complete: bool = false:
	get:
		return can_complete
	set(value):
		can_complete = value
		_check_completed.call_deferred()

func _ready() -> void:
	start.call_deferred()

func start() -> void:
	if waves is EnemyWaves && !waves.enemy_spawned.is_connected(_track_target):
		waves.enemy_spawned.connect(_track_target)

	waves.start.call_deferred()

func _track_target(enemy: Node) -> void:
	var health = Health.find(enemy)
	if health is Health:
		kills_required += 1
		health.Die.connect(_record_kill)

func _record_kill() -> void:
	kills_required -= 1
	_check_completed.call_deferred()

func _check_completed() -> void:
	if kills_required <= 0 && can_complete && !is_completed:
		is_completed = true
		complete.emit()
