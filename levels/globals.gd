extends Node
class_name GameGlobals

@export var depth: float = 0.0
@export var current_room_index: int = 0

@export var player: Player
@export var level: EndlessLevel

func reset() -> void:
	depth = 0.0
	current_room_index = 0
