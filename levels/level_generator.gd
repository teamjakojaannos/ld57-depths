extends Node
class_name LevelGenerator

@export var parts: Array[RoomPart] = []
@export var spawnlists: Array[Spawnlist] = []


const room_prefab: PackedScene = preload("uid://dmcjpau04bcb0")
const utility_prefab: PackedScene = preload("uid://me27a85v8vp3")

func _select_spawnlist() -> Spawnlist:
	var current_depth = Globals.current_room_index
	
	var allowed: Array[Spawnlist] = []
	for list in spawnlists:
		if list.is_valid_for_depth(current_depth):
			if list.is_special:
				return list
			allowed.push_back(list)
	
	return allowed.pick_random()

func _find_room_parts(slot: RoomPart.Slot, parts_list: Array[RoomPart]) -> Array[RoomPart]:
	var allowed: Array[RoomPart] = []
	for part in parts_list:
		if part.can_be_placed_in(slot):
			allowed.push_back(part) 
	
	return allowed


func generate(container: Node) -> Room:
	var parts_list: Array[RoomPart] = parts
	var spawnlist = _select_spawnlist()
	if spawnlist.is_special and !spawnlist.level_override.is_empty():
		parts_list = spawnlist.level_override
	
	if spawnlist.is_special and spawnlist.special_sequence == RoomPart.SpecialSequence.SHOP:
		Globals.money_at_checkpoint = Globals.money
	
	var is_left_utility_allowed: bool = true
	var is_right_utility_allowed: bool = true
	
	var first_slot = RoomPart.Slot.BOTTOM
	var first_part: RoomPart = _find_room_parts(first_slot, parts_list).pick_random()
	
	is_left_utility_allowed = is_left_utility_allowed && !first_part.blocks_left_utility
	is_right_utility_allowed = is_right_utility_allowed && !first_part.blocks_right_utility

	var second_part: RoomPart
	var second_slot: RoomPart.Slot
	if first_part.allowed_placement != RoomPart.AllowedPlacement.DOUBLE_SIZE:
		second_slot = RoomPart.other_slot(first_slot)
		var second_part_candidates = _find_room_parts(second_slot, parts_list)
		
		if not second_part_candidates.is_empty():
			second_part = second_part_candidates.pick_random()
			is_left_utility_allowed = is_left_utility_allowed && !second_part.blocks_left_utility
			is_right_utility_allowed = is_right_utility_allowed && !second_part.blocks_right_utility

	return _generate_from_parts(
		container,
		first_part if first_slot == RoomPart.Slot.TOP else second_part,
		second_part if first_slot == RoomPart.Slot.TOP else first_part,
		is_left_utility_allowed,
		is_right_utility_allowed,
		spawnlist
	)

func _generate_from_parts(
	container: Node,
	top_part: RoomPart,
	bottom_part: RoomPart,
	right_utility: bool,
	left_utility: bool,
	spawnlist: Spawnlist
) -> Room:
	var room: Room = room_prefab.instantiate()
	container.add_child(room)

	var require_completion = false
	if top_part is RoomPart:
		require_completion = require_completion || top_part.require_completion
		_place_part.call_deferred(room, RoomPart.Slot.TOP, top_part)
	if bottom_part is RoomPart:
		require_completion = require_completion || bottom_part.require_completion
		_place_part.call_deferred(room, RoomPart.Slot.BOTTOM, bottom_part)

	if left_utility:
		_place_utility.call_deferred(room, true)
	if right_utility:
		_place_utility.call_deferred(room, false)

	_spawn_enemies.call_deferred(room, spawnlist)

	if !require_completion:
		room.no_blocker = true
		room.unlock_exit()

	if spawnlist.entry_text_override != null && !spawnlist.entry_text_override.is_empty():
		room.entry_text = spawnlist.entry_text_override

	return room


func _spawn_enemies(room: Room, spawnlist: Spawnlist) -> void:
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
		
		spawned_enemies += 1

	room.kills_required = spawned_enemies


func _place_part(room: Room, slot: RoomPart.Slot, part: RoomPart) -> void:
	var part_prefab: PackedScene = part.scenes.pick_random()
	var part_instance: Node2D = part_prefab.instantiate()

	if slot == RoomPart.Slot.BOTTOM:
		room.bottom_slot.add_child(part_instance)
		part_instance.global_position = room.bottom_slot.global_position
	else:
		room.top_slot.add_child(part_instance)
		part_instance.global_position = room.top_slot.global_position

func _place_utility(room: Room, left: bool) -> void:
	var instance: Node2D = utility_prefab.instantiate()
	var at = room.left_slot if left else room.right_slot
	
	at.add_child(instance)
	instance.global_position = at.global_position
	if instance is BubbleElevator:
		instance.enabled = true
