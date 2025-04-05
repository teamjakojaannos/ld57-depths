extends Node2D
class_name HarpoonGun

const harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
@export var projectile_speed: float = 500.0
@export var projectile_damage: float = 1.0

func _on_harpoon_gun_fire(direction: Vector2) -> void:
	_spawn_projectile(direction)

func _spawn_projectile(direction: Vector2) -> void:
	var projectile: HarpoonProjectile = harpoon_scene.instantiate()

	var offset = position
	offset.x *= sign(direction.x)

	projectile.global_position = get_parent().global_position + offset
	projectile.speed = direction * projectile_speed
	projectile.damage = projectile_damage
	
	var current_map = Globals.level.current_level
	current_map.add_child(projectile)
