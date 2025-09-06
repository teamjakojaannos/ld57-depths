extends Node
class_name LevelGenerator

@export var spawnlists: Array[Spawnlist] = []

# kill_every_fish_room.tscn
const room_prefab: PackedScene = preload("uid://df2mycb6s5ao4")

# shop_entrance_room.tscn
const shop_prefab: PackedScene = preload("uid://njx5575ng8a")

func _select_spawnlist() -> Spawnlist:
	var current_depth = Globals.current_room_index

	var allowed: Array[Spawnlist] = []
	for list in spawnlists:
		if list.is_valid_for_depth(current_depth):
			if list.is_special:
				return list
			allowed.push_back(list)

	return allowed.pick_random()

func generate():
	var spawnlist = _select_spawnlist()

	var room: Room
	if spawnlist.is_special and spawnlist.special_sequence == RoomPart.SpecialSequence.SHOP:
		Globals.money_at_checkpoint = Globals.money

		room = shop_prefab.instantiate()
	else:
		var kill_room: KillEveryFishRoom = room_prefab.instantiate()
		kill_room.setup_room.call_deferred(spawnlist)

		room = kill_room

	if spawnlist.entry_text_override != null && !spawnlist.entry_text_override.is_empty():
		room.entry_text = spawnlist.entry_text_override

	return room
