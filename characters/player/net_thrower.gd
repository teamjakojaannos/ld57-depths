extends Node2D
class_name NetThrower

const net_attack_prefab = preload("res://characters/net_projectile.tscn")

@export var net_flying_speed = 200.0
@export var net_fall_speed = -200.0


func _on_net_thrower_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	_spawn_projectile(shooter, direction)

func _spawn_projectile(shooter: CharacterBody2D, direction: Vector2) -> void:
	var projectile: Projectile = net_attack_prefab.instantiate()
	
	projectile.global_position = global_position
	var net_direction = ($"../NetThrowDirection".global_position - global_position).normalized()
	net_direction.x = abs(net_direction.x) * sign(direction.x)

	# Net inherits 125% of upwards velocity of the shooter
	var inherited_velocity = Vector2(
		0.0,
		min(0.0, shooter.velocity.y * 1.25)
	)

	var net_velocity = net_direction * net_flying_speed
	projectile.velocity = net_velocity + inherited_velocity
	projectile.fall_speed = net_fall_speed
	
	var current_map = Globals.current_room
	current_map.add_child(projectile)
