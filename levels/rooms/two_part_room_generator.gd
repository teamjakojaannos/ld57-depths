extends Node
class_name TwoPartRoomGenerator

const room_prefab: PackedScene = preload("uid://dmcjpau04bcb0")
const utility_prefab: PackedScene = preload("uid://me27a85v8vp3")

static func generate(container: Node, parts_list: Array[RoomPart]) -> Room:
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
		is_right_utility_allowed
	)

static func _find_room_parts(slot: RoomPart.Slot, parts_list: Array[RoomPart]) -> Array[RoomPart]:
	var allowed: Array[RoomPart] = []
	for part in parts_list:
		if part.can_be_placed_in(slot):
			allowed.push_back(part)

	return allowed


static func _generate_from_parts(
	container: Node,
	top_part: RoomPart,
	bottom_part: RoomPart,
	right_utility: bool,
	left_utility: bool
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

	# FIXME: spawn blocker if completion required
	if !require_completion:
		room.no_blocker = true
		room.unlock_exit()

	return room

static func _place_part(room: Room, slot: RoomPart.Slot, part: RoomPart) -> void:
	var part_prefab: PackedScene = part.scenes.pick_random()
	var part_instance: Node2D = part_prefab.instantiate()

	if slot == RoomPart.Slot.BOTTOM:
		room.bottom_slot.add_child(part_instance)
		part_instance.global_position = room.bottom_slot.global_position
	else:
		room.top_slot.add_child(part_instance)
		part_instance.global_position = room.top_slot.global_position

static func _place_utility(room: Room, left: bool) -> void:
	var instance: Node2D = utility_prefab.instantiate()
	var at = room.left_slot if left else room.right_slot

	at.add_child(instance)
	instance.global_position = at.global_position
	if instance is BubbleElevator:
		instance.enabled = true
