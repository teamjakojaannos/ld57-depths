extends Node
class_name GameGlobals

@export var depth: float = 0.0
@export var current_room_index: int = 0

@export var player: Player
@export var level: EndlessLevel
@export var current_level: Level

@export var money: int = 100

signal level_cleared

func _ready() -> void:
	reset()

func reset() -> void:
	depth = 0.0
	current_room_index = 4

func trigger_level_clear() -> void:
	level_cleared.emit()
