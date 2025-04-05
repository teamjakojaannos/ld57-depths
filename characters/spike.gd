class_name Spike
extends Area2D

@export var damage = 1

var velocity: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(other: Node2D) -> void:
	if other is Player:
		other.take_damage(damage)
	self.queue_free()

func _lifetime_expired():
	self.queue_free()
