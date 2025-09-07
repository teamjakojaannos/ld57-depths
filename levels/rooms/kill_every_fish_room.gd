@tool
extends ObjectiveRoom
class_name KillEveryFishRoom

@onready var kill_task: KillEveryFishTask = $"Objective/KillEveryFish"
@onready var level_generator: TwoPartRoomGenerator = $TwoPartRoomGenerator

@export var spawnlist: Spawnlist


func _on_setup() -> void:
	var waves = LegacySpawnlistEnemyWaves.new()
	waves.name = "LegacySpawnlistToEnemyWavesAdapter"
	waves.spawnlist = spawnlist
	waves.min_waves = 3
	waves.max_waves = 4
	kill_task.waves = waves
	kill_task.add_child(waves, true)

	kill_task.start()

	level_generator.generate()

	objective_completed.connect(
		func():
			for node in level_generator._generated_room_nodes:
				if node is BubbleElevator:
					node.enabled = false
	)
