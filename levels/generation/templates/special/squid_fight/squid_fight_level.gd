class_name SquidFightLevel
extends Node2D

func get_random_tentacle_spawn() -> TentacleMarkers:
	return $TentacleSpawns.get_children().pick_random()
