extends Node2D
class_name NetThrower

const net_attack_prefab = preload("res://characters/net_projectile.tscn")

@export var net_flying_speed = 200.0
@export var net_fall_speed = -200.0


func _on_net_thrower_fire(direction: Vector2) -> void:
	_spawn_projectile(direction)

func _spawn_projectile(direction: Vector2) -> void:
	var projectile: Projectile = net_attack_prefab.instantiate()
	
	projectile.global_position = global_position
	var net_direction = ($"../NetThrowDirection".global_position - global_position).normalized()
	net_direction.x = abs(net_direction.x) * sign(direction.x)

	var net_velocity = net_direction * net_flying_speed
	projectile.velocity = net_velocity
	projectile.fall_speed = net_fall_speed
	
	var current_map = Globals.level.current_level
	current_map.add_child(projectile)
