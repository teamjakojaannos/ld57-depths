class_name HarpoonProjectile
extends Area2D

var speed = 100.0

func _physics_process(delta: float) -> void:
	position.x += speed * delta

func _on_body_entered(other: Node2D) -> void:
	print("harpoon hit something...")
	self.queue_free()
