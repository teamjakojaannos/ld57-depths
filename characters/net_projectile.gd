class_name NetProjectile
extends Area2D

var initial_velocity: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	position += initial_velocity * delta
