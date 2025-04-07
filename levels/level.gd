extends Node2D
class_name Level

signal Finished

const spike_fish_prefab = preload("res://fish/spiky_puffer_fish/spike_fish.tscn")

var _kills: int = 0
var kills_required: int = 999

var entry_text: Array[String] = []

@export var no_blocker: bool = false

@onready var top_slot: Node2D = $TopLevelPart
@onready var bottom_slot: Node2D = $BottomLevelPart
@onready var left_slot: Node2D = $LeftUtility
@onready var right_slot: Node2D = $RightUtility


func finish() -> void:
	Finished.emit()

func unlock_exit() -> void:
	$Blocker.queue_free()
	Globals.trigger_level_clear()
	
	for child in $LeftUtility.get_children():
		if child is BubbleElevator:
			child.enabled = false

	for child in $RightUtility.get_children():
		if child is BubbleElevator:
			child.enabled = false
	
func _ready() -> void:
	if no_blocker:
		unlock_exit()

func record_kill() -> void:
	Globals.money += 1
	_kills += 1

	if _kills >= kills_required:
		Globals.level.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
		unlock_exit()

func get_random_fish_nav_point() -> Vector2:
	var nav_area: CollisionShape2D = $"FishNavArea/Shape"
	var rect: Rect2 = nav_area.shape.get_rect()
	var x = randf_range(-rect.size.x, rect.size.x) / 2.0
	var y = randf_range(-rect.size.y, rect.size.y) / 2.0
	return Vector2(x, y) + nav_area.position
