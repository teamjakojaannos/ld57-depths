@tool
extends Node
class_name Bounty

@export var bounty: int = 1

@export_group("Advanced")
@export var health: Health

func _ready() -> void:
	health = Nodes.find_if_null(get_parent(), health, Health)

	if not Objects.is_null(health):
		Signals.try_connect(health.die, _on_health_die)

func _on_health_die() -> void:
	Globals.money += bounty
