extends Task
class_name KillEveryFishTask

@export var waves: EnemyWaves

var kills_required: int = 0

func _ready() -> void:
	can_complete = false

	if waves != null:
		start.call_deferred()

func start() -> void:
	if waves is EnemyWaves && !waves.enemy_spawned.is_connected(_track_target):
		waves.enemy_spawned.connect(_track_target)

	await waves.run()
	can_complete = true

func _track_target(enemy: Node) -> void:
	var health = Nodes.find_by_class(enemy, Health)
	if health is Health:
		kills_required += 1
		health.die.connect(_record_kill)

func _record_kill() -> void:
	kills_required -= 1
	_check_completed.call_deferred()

func _is_completed() -> bool:
	return kills_required <= 0
