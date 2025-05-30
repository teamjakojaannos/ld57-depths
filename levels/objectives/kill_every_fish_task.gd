extends Node
class_name KillEveryFishTask

signal complete

@export var room: Room
@export var spawnlist: Spawnlist

var kills_required: int = 1

func _ready() -> void:
	_spawn_enemies.call_deferred()

func _spawn_enemies() -> void:
	var spawned_enemies = 0
	var spent_cost = 0
	while spent_cost < spawnlist.total_cost:
		var s: Spawnable = spawnlist.enemies.pick_random()
		spent_cost += s.spawn_cost

		var spawn_group: String
		match s.spawnpoint_group:
			Spawnable.SpawnGroup.NORMAL:
				spawn_group = "enemy_spawn"
			Spawnable.SpawnGroup.PATH_FOLLOWER:
				spawn_group = "path_enemy_spawn"
			_:
				print("Unexpected spawnpoint group %s" % s.spawnpoint_group)
				spawn_group = "enemy_spawn"

		# FIXME: cache these
		var enemy_spawns = get_tree().get_nodes_in_group(spawn_group)
		var allowed_spawns: Array[Node2D] = []
		for spawnpoint in enemy_spawns:
			if !room.is_ancestor_of(spawnpoint):
				continue
			if spawnpoint is Node2D:
				allowed_spawns.push_back(spawnpoint)
		
		var spawnpoint = allowed_spawns.pick_random()
		var enemy: Node2D = s.prefab.instantiate()
		match s.spawnpoint_group:
			Spawnable.SpawnGroup.NORMAL:
				room.add_child(enemy)
			Spawnable.SpawnGroup.PATH_FOLLOWER:
				spawnpoint.add_child(enemy)
		enemy.global_position = spawnpoint.global_position

		_track_target.call_deferred(enemy)
		
		spawned_enemies += 1

	# FIXME: remove
	room.kills_required = spawned_enemies
	kills_required = spawned_enemies


func _track_target(target: Node) -> void:
	var health = target.get_node("Health")
	if health is Health:
		health.Die.connect(_record_kill)

func _record_kill() -> void:
	kills_required -= 1

	if kills_required <= 0:
		complete.emit()
