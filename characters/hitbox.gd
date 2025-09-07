## A region of 2D space that can accept incoming damage.
@tool
extends Area2D
class_name Hitbox

@export var health: Health

@export var multiplier: int = 1

func _ready() -> void:
	if health == null:
		health = get_parent().get_node_or_null("Health")
