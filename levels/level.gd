extends Node2D
class_name Level

signal Finished

const spike_fish_prefab = preload("res://fish/spiky_puffer_fish/spike_fish.tscn")

var _kills: int = 0
var _kills_required: int = 999

@export var no_blocker: bool = false


func finish() -> void:
	Finished.emit()

func unlock_exit() -> void:
	$Blocker.queue_free()
	$LeftUtility/BubbleElevator.enabled = false
	$RightUtility/BubbleElevator.enabled = false
	
func _ready() -> void:
	if no_blocker:
		unlock_exit()


func generate(
	part_prefabs: Array[PackedScene],
	enemy_prefabs: Array[PackedScene],
) -> void:
	if not part_prefabs.is_empty():
		spawn_level_part($TopLevelPart, part_prefabs.pick_random())
		spawn_level_part($BottomLevelPart, part_prefabs.pick_random())

	if not enemy_prefabs.is_empty():
		var spawn_count = 1
		for _i in spawn_count:
			spawn_enemy(enemy_prefabs.pick_random())

		_kills_required = spawn_count


func spawn_level_part(at: Marker2D, prefab: PackedScene) -> void:
	var part = prefab.instantiate()
	at.add_child(part)

func spawn_enemy(prefab: PackedScene):
	var spawn_points = $SpikeFishSpawns.get_children()
	if spawn_points.size() == 0:
		return
	var spawn_point = spawn_points.pick_random()

	var fish: Node2D = prefab.instantiate()
	fish.position = spawn_point.position
	add_child(fish)

func record_kill() -> void:
	_kills += 1

	if _kills >= _kills_required:
		Globals.level.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
		unlock_exit()
