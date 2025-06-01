extends Node
class_name EnemyWave

@export_category("Enemy to spawn")
@export var enemy: PackedScene
@export var count_min: int = 1
@export var count_max: int = 2

@export_group("Advanced")
@export
## The global node group used to determine possible spawnpoints
##  - Normal = enemy_spawn
##  - Path follower = path_enemy_spawn
var spawn_group: Spawnable.SpawnGroup = Spawnable.SpawnGroup.NORMAL

func spawn() -> Array[Node]:
	# NOTE:
	# this might be dangerous in case some special spawning script continues as
	# player progresses to the next level.
	var room = Globals.current_room
	var objective = Globals.current_objective

	# HACK: simulate spawn anim with a delay
	# FIXME: add spawn anims/sequences to enemies
	await get_tree().create_timer(0.5).timeout

	var spawned_enemies: Array[Node] = []
	for _i in randi_range(count_min, count_max):
		var enemy = _spawn_enemy(room)
		spawned_enemies.push_back(enemy)

	return spawned_enemies


func _spawn_enemy(room: Room) -> Node2D:
	var allowed_spawns = _find_spawnpoints_in_group(room, spawn_group)
	var spawnpoint = allowed_spawns.pick_random()
	var instance: Node2D = enemy.instantiate()
	match spawn_group:
		Spawnable.SpawnGroup.NORMAL:
			room.add_child(instance)
		Spawnable.SpawnGroup.PATH_FOLLOWER:
			spawnpoint.add_child(instance)
	instance.global_position = spawnpoint.global_position
	
	return instance


static func _find_spawnpoints_in_group(room: Room, spawn_group: Spawnable.SpawnGroup) -> Array[Node2D]:
	var spawn_group_name = _spawngroup_to_name(spawn_group)

	var enemy_spawns = room.get_tree().get_nodes_in_group(spawn_group_name)
	var allowed_spawns: Array[Node2D] = []
	for spawnpoint in enemy_spawns:
		if !room.is_ancestor_of(spawnpoint):
			continue
		if spawnpoint is Node2D:
			allowed_spawns.push_back(spawnpoint)
	
	return allowed_spawns


static func _spawngroup_to_name(group: Spawnable.SpawnGroup) -> String:
	var spawn_group_name: String
	match group:
		Spawnable.SpawnGroup.NORMAL:
			spawn_group_name = "enemy_spawn"
		Spawnable.SpawnGroup.PATH_FOLLOWER:
			spawn_group_name = "path_enemy_spawn"
		_:
			print("Unexpected spawnpoint group %s" % group)
			spawn_group_name = "enemy_spawn"

	return spawn_group_name
