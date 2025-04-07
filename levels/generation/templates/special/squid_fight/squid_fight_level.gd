class_name SquidFightLevel
extends Node2D

func get_random_tentacle_spawn() -> TentacleMarkers:
	return $TentacleSpawns.get_children().pick_random()

func get_tentacle_sequence_positions() -> Array[TentacleMarkers]:
	var result: Array[TentacleMarkers]
	result.append($TentacleSequence/First)
	result.append($TentacleSequence/Second)
	result.append($TentacleSequence/Third)
	return result
