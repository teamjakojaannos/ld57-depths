extends Node2D
class_name Level

signal Finished

const spike_fish_prefab = preload("res://characters/spike_fish.tscn")

func _ready() -> void:
	spawn_enemies()

func finish() -> void:
	Finished.emit()

func spawn_enemies():
	var spawn_points = $SpikeFishSpawns.get_children()
	if spawn_points.size() == 0:
		return
	var spawn_point = spawn_points.pick_random()

	var fish: Node2D = spike_fish_prefab.instantiate()
	fish.position = spawn_point.position
	add_child(fish)
