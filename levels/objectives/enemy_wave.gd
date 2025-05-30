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

func spawn() -> void:
	# HACK: simulate spawn anim with a delay
	await get_tree().create_timer(0.5).timeout
	
	for _i in randi_range(count_min, count_max):
		_spawn()
	
func _spawn() -> void:
	var spawn_group_name: String
	match spawn_group:
		Spawnable.SpawnGroup.NORMAL:
			spawn_group_name = "enemy_spawn"
		Spawnable.SpawnGroup.PATH_FOLLOWER:
			spawn_group_name = "path_enemy_spawn"
		_:
			print("Unexpected spawnpoint group %s" % spawn_group)
			spawn_group_name = "enemy_spawn"

	# NOTE:
	# this might be dangerous in case some special spawning script continues as
	# player progresses to the next level.
	var room = Globals.current_room

	# FIXME: cache these
	var enemy_spawns = get_tree().get_nodes_in_group(spawn_group_name)
	var allowed_spawns: Array[Node2D] = []
	for spawnpoint in enemy_spawns:
		if !room.is_ancestor_of(spawnpoint):
			continue
		if spawnpoint is Node2D:
			allowed_spawns.push_back(spawnpoint)
	
	var spawnpoint = allowed_spawns.pick_random()
	var instance: Node2D = enemy.instantiate()
	match spawn_group:
		Spawnable.SpawnGroup.NORMAL:
			room.add_child(instance)
		Spawnable.SpawnGroup.PATH_FOLLOWER:
			spawnpoint.add_child(instance)
	instance.global_position = spawnpoint.global_position

	# TODO: tell the objective/task that these fckers need to be killed
	# _track_target.call_deferred(instance)
	# spawned_enemies += 1
