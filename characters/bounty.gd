@tool
extends Node
class_name Bounty

@export var bounty: int = 1

@export_group("Advanced")
@export var health: Health

func _ready() -> void:
	Components.set_default_sibling(self, "health", "Health")
	Components.try_connect_to(health, "die", _on_health_die)

func _on_health_die() -> void:
	Globals.money += bounty
