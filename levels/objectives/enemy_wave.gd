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
var spawn_group: SpawnGroup = SpawnGroup.LEGACY

enum SpawnGroup {
	## Default/legacy behaviour: The enemy is spawned on-screen,
	## on a pre-placed spawnpoint.
	LEGACY,

	## The enemy spawns off-screen, on a side of the play area.
	## It is up to the enemy AI to route it towards the play-area.
	OFF_SCREEN_SIDE,

	## The enemy spawns directly within the play area. Position
	## is selected on one of the path(s) surrounding platforms
	## within the level.
	ON_PLATFORM_PATH,
}

func spawn() -> Array[Node]:
	# NOTE:
	# this might be dangerous in case some special spawning script continues as
	# player progresses to the next level.
	var room = Globals.current_room

	# HACK: simulate spawn anim with a delay
	# FIXME: add spawn anims/sequences to enemies
	await get_tree().create_timer(0.5).timeout

	var spawned_enemies: Array[Node] = []
	for i in randi_range(count_min, count_max):
		var instance = _spawn_enemy(room)
		spawned_enemies.push_back(instance)

	return spawned_enemies


func _spawn_enemy(room: Room) -> Node2D:
	var instance: Node2D = enemy.instantiate()
	_place_at_spawnpoint(instance, room, spawn_group)
	
	return instance

static func _place_at_spawnpoint(instance: Node2D, room: Room, group: SpawnGroup) -> void:
	match group:
		SpawnGroup.OFF_SCREEN_SIDE:
			var spawn_y = randf_range(room.bounds.position.y, room.bounds.end.y)
			var spawn_x: float = 0.0
			match ["left", "right"].pick_random():
				"left":
					spawn_x = room.bounds.position.x
				"right":
					spawn_x = room.bounds.end.x

			room.add_child(instance)
			instance.global_position = room.global_position
			instance.global_position += Vector2(spawn_x, spawn_y)

		# Legacy behaviour
		_:
			var allowed_spawns = _find_spawnpoints_in_group(room, group)
			var spawnpoint: Node2D = allowed_spawns.pick_random()
			var parent = room
			if group == SpawnGroup.ON_PLATFORM_PATH:
				parent = spawnpoint
			parent.add_child(instance)
			instance.global_position = spawnpoint.global_position

static func _find_spawnpoints_in_group(room: Room, group: SpawnGroup) -> Array[Node2D]:
	var spawn_group_name = _spawngroup_to_name(group)

	var enemy_spawns = room.get_tree().get_nodes_in_group(spawn_group_name)
	var allowed_spawns: Array[Node2D] = []
	for spawnpoint in enemy_spawns:
		if !room.is_ancestor_of(spawnpoint):
			continue
		if spawnpoint is Node2D:
			allowed_spawns.push_back(spawnpoint)
	
	return allowed_spawns


static func _spawngroup_to_name(group: SpawnGroup) -> String:
	var spawn_group_name: String
	match group:
		SpawnGroup.LEGACY:
			spawn_group_name = "enemy_spawn"
		SpawnGroup.ON_PLATFORM_PATH:
			spawn_group_name = "path_enemy_spawn"
		_:
			print("Unexpected spawnpoint group %s" % group)
			spawn_group_name = "enemy_spawn"

	return spawn_group_name
