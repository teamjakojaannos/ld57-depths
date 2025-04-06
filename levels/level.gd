extends Node2D
class_name Level

signal Finished

const spike_fish_prefab = preload("res://fish/spiky_puffer_fish/spike_fish.tscn")

var _kills: int = 0
var kills_required: int = 999

@export var no_blocker: bool = false

@onready var top_slot: Node2D = $TopLevelPart
@onready var bottom_slot: Node2D = $BottomLevelPart
@onready var left_slot: Node2D = $LeftUtility
@onready var right_slot: Node2D = $RightUtility


func finish() -> void:
	Finished.emit()

func unlock_exit() -> void:
	$Blocker.queue_free()
	
func _ready() -> void:
	if no_blocker:
		unlock_exit()

func record_kill() -> void:
	_kills += 1

	if _kills >= kills_required:
		Globals.level.objective_overlay.show_objective("Proceed", "to", "depths", 1.5)
		unlock_exit()
