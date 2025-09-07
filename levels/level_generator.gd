extends Node
class_name LevelGenerator

@export var spawnlists: Array[Spawnlist] = []

# kill_every_fish_room.tscn
const room_prefab: PackedScene = preload("uid://df2mycb6s5ao4")

# shop_entrance_room.tscn
const shop_prefab: PackedScene = preload("uid://njx5575ng8a")

# tutorial_jump_room.tscn
const tutorial_prefab: PackedScene = preload("uid://dxtelu0c315cw")

# boss_crab_room_1.tscn
const boss_crab_prefab: PackedScene = preload("uid://ktgvv5vwps2c")

# boss_squid_room_1.tscn
const boss_squid_prefab: PackedScene = preload("uid://b26rtbfbjllcy")


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

	match spawnlist.special_sequence:
		RoomPart.SpecialSequence.NONE:
			var kill_room: KillEveryFishRoom = room_prefab.instantiate()
			kill_room.spawnlist = spawnlist
			return kill_room
		RoomPart.SpecialSequence.TUTORIAL:
			return tutorial_prefab.instantiate()
		RoomPart.SpecialSequence.SHOP:
			Globals.money_at_checkpoint = Globals.money
			return shop_prefab.instantiate()
		RoomPart.SpecialSequence.CRAB_RAVE:
			return boss_crab_prefab.instantiate()
		RoomPart.SpecialSequence.SQUID_FIGHT:
			return boss_squid_prefab.instantiate()
		var unknown:
			push_error("Unhandled room \"%s\"" % unknown)
			return null
