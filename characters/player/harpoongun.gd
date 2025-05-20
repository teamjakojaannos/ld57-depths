extends Node2D
class_name HarpoonGun

const harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
const harpoon_scene_better = preload("res://characters/harpoon_projectile_but_better.tscn")
@export var projectile_speed: float = 500.0
@export var projectile_damage: float = 1.0

@export var crouch_offset: float = 9.0

func _on_harpoon_gun_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	_spawn_projectile(shooter, direction)

func _spawn_projectile(shooter: CharacterBody2D, direction: Vector2) -> void:
	var prefab = harpoon_scene
	if projectile_damage >= 3.0:
		prefab = harpoon_scene_better

	var projectile: Projectile = prefab.instantiate()

	var offset = position
	offset.x *= sign(direction.x)
	if shooter is Player:
		if shooter.is_crouching:
			offset += Vector2.DOWN * crouch_offset

	projectile.global_position = get_parent().global_position + offset
	projectile.velocity = direction * projectile_speed
	projectile.damage = projectile_damage

	var current_map = Globals.current_room
	current_map.add_child(projectile)
