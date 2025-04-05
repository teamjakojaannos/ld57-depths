extends Node2D
class_name Level

signal Finished

const spike_fish_prefab = preload("res://fish/spiky_puffer_fish/spike_fish.tscn")

func finish() -> void:
	Finished.emit()

func generate(
	part_prefabs: Array[PackedScene],
	enemy_prefabs: Array[PackedScene],
) -> void:
	if not part_prefabs.is_empty():
		spawn_level_part($TopLevelPart, part_prefabs.pick_random())
		spawn_level_part($BottomLevelPart, part_prefabs.pick_random())

	if not enemy_prefabs.is_empty():
		spawn_enemies(enemy_prefabs.pick_random())

func spawn_level_part(at: Marker2D, prefab: PackedScene) -> void:
	var part = prefab.instantiate()
	at.add_child(part)

func spawn_enemies(prefab: PackedScene):
	var spawn_points = $SpikeFishSpawns.get_children()
	if spawn_points.size() == 0:
		return
	var spawn_point = spawn_points.pick_random()

	var fish: Node2D = prefab.instantiate()
	fish.position = spawn_point.position
	add_child(fish)
