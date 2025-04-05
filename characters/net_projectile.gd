class_name NetProjectile
extends Area2D

var velocity: Vector2 = Vector2()
var fall_speed = -200.0
var damage = 1

func _physics_process(delta: float) -> void:
	velocity.y -= fall_speed * delta
	position += velocity * delta

func _on_area_entered(other: Area2D) -> void:
	if other is SpikeFish:
		other.take_damage(damage)
		queue_free()
