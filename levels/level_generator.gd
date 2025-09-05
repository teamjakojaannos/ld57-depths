extends Node
class_name LevelGenerator

@export var spawnlists: Array[Spawnlist] = []

# kill_every_fish_room.tscn
const room_prefab: PackedScene = preload("uid://df2mycb6s5ao4")

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

	if spawnlist.is_special and spawnlist.special_sequence == RoomPart.SpecialSequence.SHOP:
		Globals.money_at_checkpoint = Globals.money

	var room: KillEveryFishRoom = room_prefab.instantiate()
	room.setup_room.call_deferred(spawnlist)

	return room
