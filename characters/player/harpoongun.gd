extends Node2D
class_name HarpoonGun

const harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
@export var projectile_speed: float = 500.0
@export var projectile_damage: float = 1.0

func _on_harpoon_gun_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	_spawn_projectile(shooter, direction)

func _spawn_projectile(_shooter: CharacterBody2D, direction: Vector2) -> void:
	var projectile: Projectile = harpoon_scene.instantiate()

	var offset = position
	offset.x *= sign(direction.x)

	projectile.global_position = get_parent().global_position + offset
	projectile.velocity = direction * projectile_speed
	projectile.damage = projectile_damage
	
	var current_map = Globals.current_level
	current_map.add_child(projectile)
