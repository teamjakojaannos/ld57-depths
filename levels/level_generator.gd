extends Node
class_name LevelGenerator

@export var parts: Array[RoomPart] = []
@export var spawnlists: Array[Spawnlist] = []

func _select_spawnlist() -> Spawnlist:
	var current_depth = Globals.current_room_index

	var allowed: Array[Spawnlist] = []
	for list in spawnlists:
		if list.is_valid_for_depth(current_depth):
			if list.is_special:
				return list
			allowed.push_back(list)

	return allowed.pick_random()

func generate(container: Node) -> Room:
	var parts_list: Array[RoomPart] = parts
	var spawnlist = _select_spawnlist()
	if spawnlist.is_special and !spawnlist.level_override.is_empty():
		parts_list = spawnlist.level_override

	if spawnlist.is_special and spawnlist.special_sequence == RoomPart.SpecialSequence.SHOP:
		Globals.money_at_checkpoint = Globals.money

	var room = TwoPartRoomGenerator.generate(container, parts_list)

	var objective = Objective.new()
	room.add_child(objective)
	_setup_objective.call_deferred(room, spawnlist, objective)

	# FIXME: spawn blocker if completion required
	var requires_completion = !room.no_blocker
	if requires_completion:
		objective.complete.connect(room.unlock_exit)
		objective.complete.connect(
			func():
				UI.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
		)

	if spawnlist.entry_text_override != null && !spawnlist.entry_text_override.is_empty():
		room.entry_text = spawnlist.entry_text_override

	return room

func _setup_objective(room: Room, spawnlist: Spawnlist, objective: Objective) -> void:
	var task = KillEveryFishTask.new()
	task.room = room

	var waves = LegacySpawnlistEnemyWaves.new()
	waves.name = "LegacySpawnlistToEnemyWavesAdapter"
	waves.spawnlist = spawnlist
	waves.min_waves = 1
	waves.max_waves = 3
	task.waves = waves
	task.add_child(waves, true)
	objective.add_child(task)

	objective.track_task(task)
	task.start.call_deferred()
	Globals.current_objective = objective
