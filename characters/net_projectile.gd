class_name NetProjectile
extends Area2D

var velocity: Vector2 = Vector2()
var fall_speed = -200.0

func _physics_process(delta: float) -> void:
	velocity.y -= fall_speed * delta
	position += velocity * delta
