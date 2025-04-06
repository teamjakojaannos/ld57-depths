extends Node
class_name LevelGenerator

@export var parts: Array[LevelPart] = []
@export var spawnlists: Array[Spawnlist] = []

# level.tscn
const level_base: PackedScene = preload("uid://dmcjpau04bcb0")

# bubble_elevator.tscn
const utility_prefab: PackedScene = preload("uid://me27a85v8vp3")

func _select_spawnlist() -> Spawnlist:
	var current_depth = Globals.current_room_index
	
	var allowed: Array[Spawnlist] = []
	for list in spawnlists:
		if current_depth <= list.min_depth:
			continue
		if list.max_depth != -1 and current_depth > list.max_depth:
			continue
		allowed.push_back(list)
	
	return allowed.pick_random()

func _find_level_parts(slot: LevelPart.Slot) -> Array[LevelPart]:
	var current_depth = Globals.current_room_index
	
	var allowed: Array[LevelPart] = []
	for part in parts:
		if part.can_be_placed_in(slot):
			allowed.push_back(part) 
	
	return allowed

func generate(container: Node) -> Level:
	var level: Level = level_base.instantiate()
	container.add_child(level)

	var is_left_utility_allowed: bool = true
	var is_right_utility_allowed: bool = true
	
	var first_slot = LevelPart.Slot.TOP if randf() < 0.5 else LevelPart.Slot.BOTTOM
	var first_part: LevelPart = _find_level_parts(first_slot).pick_random()
	
	_place_part.call_deferred(level, first_slot, first_part)
	is_left_utility_allowed = is_left_utility_allowed && !first_part.blocks_left_utility
	is_right_utility_allowed = is_right_utility_allowed && !first_part.blocks_right_utility

	if first_part.allowed_placement != LevelPart.AllowedPlacement.DOUBLE_SIZE:
		var second_slot = LevelPart.other_slot(first_slot)
		var second_part_candidates = _find_level_parts(second_slot)
		
		if not second_part_candidates.is_empty():
			var second_part = second_part_candidates.pick_random()
			_place_part.call_deferred(level, second_slot, second_part)
			is_left_utility_allowed = is_left_utility_allowed && !second_part.blocks_left_utility
			is_right_utility_allowed = is_right_utility_allowed && !second_part.blocks_right_utility

	if is_left_utility_allowed:
		_place_utility.call_deferred(level, true)
	if is_right_utility_allowed:
		_place_utility.call_deferred(level, false)

	_spawn_enemies.call_deferred(level)

	return level


func _spawn_enemies(level: Level) -> void:
	var spawnlist = _select_spawnlist()

	var spawned_enemies = 0
	var spent_cost = 0
	while spent_cost < spawnlist.total_cost:
		var s: Spawnable = spawnlist.enemies.pick_random()
		spent_cost += s.spawn_cost

		# FIXME: cache these
		var enemy_spawns = get_tree().get_nodes_in_group(s.spawnpoint_group)
		var allowed_spawns: Array[Node2D] = []
		for spawnpoint in enemy_spawns:
			if !level.is_ancestor_of(spawnpoint):
				continue
			if spawnpoint is Node2D:
				allowed_spawns.push_back(spawnpoint)
		
		var spawnpoint = allowed_spawns.pick_random()
		var enemy: Node2D = s.prefab.instantiate()
		level.add_child(enemy)
		var point = spawnpoint.global_position
		enemy.global_position = point
		
		spawned_enemies += 1

	level.kills_required = spawned_enemies


func _place_part(level: Level, slot: LevelPart.Slot, part: LevelPart) -> void:
	var part_prefab: PackedScene = part.scenes().pick_random()
	var part_instance: Node2D = part_prefab.instantiate()

	if slot == LevelPart.Slot.BOTTOM:
		level.bottom_slot.add_child(part_instance)
		part_instance.global_position = level.bottom_slot.global_position
	else:
		level.top_slot.add_child(part_instance)
		part_instance.global_position = level.top_slot.global_position

func _place_utility(level: Level, left: bool) -> void:
	var instance: Node2D = utility_prefab.instantiate()
	var at = level.left_slot if left else level.right_slot
	
	at.add_child(instance)
	instance.global_position = at.global_position
	if instance is BubbleElevator:
		instance.enabled = true
