@tool
extends Area2D
class_name Hurtbox

@export var health: Health

func _ready() -> void:
	if health == null:
		health = get_parent().get_node_or_null("Health")
