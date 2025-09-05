@tool
extends Node
class_name TwoPartRoomGenerator

@export
var room_parts: Array[RoomPart] = []

@export
var room: Node2D

## Marker node for the position where the top part of the level will be
## generated at.
@export var top_part_slot: Node2D

## Marker node for the position where the bottom part of the level will be
## generated at.
@export var bottom_part_slot: Node2D

@export var left_utility_slot: Node2D
@export var right_utility_slot: Node2D

var _generated_room_nodes: Array[Node2D] = []

@export_tool_button("Generate", "Callable")
var debug_generate_action = debug_generate

@export_tool_button("Clear", "Callable")
var debug_clear_action = clear


const utility_prefab: PackedScene = preload("uid://me27a85v8vp3")

func _ready() -> void:
	if room == null && get_parent() is Node2D:
		room = get_parent()

func clear() -> void:
	for node in _generated_room_nodes:
		node.queue_free()
	_generated_room_nodes.clear()

func debug_generate() -> void:
	clear()
	generate()

func generate() -> void:
	if room_parts.size() == 0:
		return

	var is_left_utility_allowed: bool = true
	var is_right_utility_allowed: bool = true

	var first_slot = RoomPart.Slot.BOTTOM
	var first_part: RoomPart = _find_room_parts(first_slot, room_parts).pick_random()

	is_left_utility_allowed = is_left_utility_allowed && !first_part.blocks_left_utility
	is_right_utility_allowed = is_right_utility_allowed && !first_part.blocks_right_utility

	var second_part: RoomPart
	var second_slot: RoomPart.Slot
	if first_part.allowed_placement != RoomPart.AllowedPlacement.DOUBLE_SIZE:
		second_slot = RoomPart.other_slot(first_slot)
		var second_part_candidates = _find_room_parts(second_slot, room_parts)

		if not second_part_candidates.is_empty():
			second_part = second_part_candidates.pick_random()
			is_left_utility_allowed = is_left_utility_allowed && !second_part.blocks_left_utility
			is_right_utility_allowed = is_right_utility_allowed && !second_part.blocks_right_utility

	_generate_from_parts(
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


func _generate_from_parts(
	top_part: RoomPart,
	bottom_part: RoomPart,
	right_utility: bool,
	left_utility: bool
) -> void:
	if top_part is RoomPart:
		_place_part(RoomPart.Slot.TOP, top_part)
	if bottom_part is RoomPart:
		_place_part(RoomPart.Slot.BOTTOM, bottom_part)

	if left_utility:
		_place_utility(true)
	if right_utility:
		_place_utility(false)


func _place_part(slot: RoomPart.Slot, part: RoomPart) -> void:
	var part_prefab: PackedScene = part.scenes.pick_random()
	var instance: Node2D = part_prefab.instantiate()
	_generated_room_nodes.push_back(instance)

	var is_top = slot == RoomPart.Slot.TOP
	var at = top_part_slot if is_top else bottom_part_slot
	at.add_child(instance)
	instance.global_position = at.global_position


func _place_utility(left: bool) -> void:
	var instance: Node2D = utility_prefab.instantiate()
	var at = left_utility_slot if left else right_utility_slot
	_generated_room_nodes.push_back(instance)

	at.add_child(instance)
	instance.global_position = at.global_position
