@tool
extends Node
class_name Health

signal Die
signal Heal
signal Hurt

@export var max_health: float = 10:
	get:
		return max_health
	set(value):
		max_health = value
		health = min(health, max_health)

@export var health: float = 10:
	get:
		return health
	set(value):
		var old_health = health
		health = clamp(value, 0, max_health)

		if Engine.is_editor_hint():
			return

		var change = health - old_health
		if change > 0:
			Heal.emit()
		elif change < 0:
			Hurt.emit()
		
		if health <= 0:
			Die.emit()

var is_dead: bool:
	get:
		return health <=  0

func _ready() -> void:
	health = max_health
