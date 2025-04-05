class_name Spike
extends RigidBody2D

@export var damage = 1

func _physics_process(_delta: float):
	for node in get_colliding_bodies():
		if node is Player:
			node.take_damage(damage)
		self.queue_free()


func _lifetime_expired():
	self.queue_free()
