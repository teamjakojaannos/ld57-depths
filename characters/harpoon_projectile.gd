class_name HarpoonProjectile
extends Area2D

var speed: Vector2 = Vector2.RIGHT * 100.0
var damage: int = 1

func _physics_process(delta: float) -> void:
	position += speed * delta
	rotation = speed.angle()
	
func _on_area_entered(other: Area2D) -> void:
	if other is SpikeFish:
		other.take_damage(damage)
	self.queue_free()
