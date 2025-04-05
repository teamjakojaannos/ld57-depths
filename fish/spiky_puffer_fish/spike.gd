class_name Spike
extends Area2D

@export var damage = 1

var velocity: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(other: Node2D) -> void:
	var health = other.get_node_or_null("Health")
	if health is Health:
		health.health -= damage
	self.queue_free()

func _lifetime_expired():
	self.queue_free()
