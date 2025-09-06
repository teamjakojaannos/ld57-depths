@tool
extends Room
class_name KillEveryFishRoom

@onready var objective: Objective = $Objective
@onready var kill_task: KillEveryFishTask = $"Objective/KillEveryFish"
@onready var level_generator: TwoPartRoomGenerator = $TwoPartRoomGenerator

func setup_room(spawnlist: Spawnlist) -> void:
	var waves = LegacySpawnlistEnemyWaves.new()
	waves.name = "LegacySpawnlistToEnemyWavesAdapter"
	waves.spawnlist = spawnlist
	waves.min_waves = 1
	waves.max_waves = 3
	kill_task.waves = waves
	kill_task.add_child(waves, true)

	if spawnlist.is_special and !spawnlist.level_override.is_empty():
		level_generator.room_parts = spawnlist.level_override

	level_generator.generate()

	var requires_completion = \
		spawnlist.special_sequence == RoomPart.SpecialSequence.NONE
	if requires_completion:
		objective.complete.connect(unlock_exit)
		objective.complete.connect(
			func():
				UI.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
				for node in level_generator._generated_room_nodes:
					if node is BubbleElevator:
						node.enabled = false
		)
	else:
		unlock_exit()
