extends Node
class_name GameGlobals

@export var depth: float = 0.0
@export var current_room_index: int = 0

@export var player: Player
@export var level: EndlessLevel
@export var current_level: Level

func _ready() -> void:
	reset()

func reset() -> void:
	depth = 0.0
	current_room_index = 0
