extends Node2D
class_name HarpoonGun

@onready var player: Player = $".."

const harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
var is_harpoon_ready = true

@export var harpoon_cooldown: float = 0.1
@export var harpoon_speed: float = 500.0
@export var harpoon_damage: float = 1.0

@export var knockback: float = 20.0
@export var slowdown: float = 0.15

func do_harpoon_attack():
	if !is_harpoon_ready or player.is_in_transition or player.is_dead:
		return
	
	var projectile: HarpoonProjectile = harpoon_scene.instantiate()
	projectile.global_position = $HarpoonSpawn.global_position
	var direction = Vector2(player.looking_at_scalar, 0.0)
	projectile.speed = direction * harpoon_speed
	projectile.damage = harpoon_damage
	
	var knockback_direction = direction * -1.0
	player.push(knockback_direction * knockback)
	player.apply_slow(slowdown, 0.5)

	var current_map = Globals.level.current_level
	current_map.add_child(projectile)
	
	is_harpoon_ready = false
	await get_tree().create_timer(harpoon_cooldown).timeout
	is_harpoon_ready = true


func _process(_delta: float) -> void:
	match player.looking_at:
		Player.LookingAt.LEFT:
			scale.x = abs(scale.x) * -1
		Player.LookingAt.RIGHT:
			scale.x = abs(scale.x) * 1
