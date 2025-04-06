extends Node2D

@export var cooldown: float = 0.1

@export var knockback: float = 20.0
@export var slowdown: float = 0.15

var _is_ready: bool = true

signal Fire(shooter: CharacterBody2D, direction: Vector2)

func fire(shooter: Player, direction: Vector2):
	if !_is_ready:
		return

	Fire.emit(shooter, direction)
	
	var knockback_direction = direction * -1.0
	shooter.push(knockback_direction * knockback)
	shooter.apply_slow(slowdown, 0.5)
	
	_is_ready = false
	await get_tree().create_timer(cooldown).timeout
	_is_ready = true
