class_name HarpoonProjectile
extends Area2D

var speed = 100.0
var damage = 1

func _physics_process(delta: float) -> void:
	position.x += speed * delta
	
func _on_area_entered(other: Area2D) -> void:
	if other is SpikeFish:
		other.take_damage(damage)
	self.queue_free()
