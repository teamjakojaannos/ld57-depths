extends Marker2D

const anchor_prefab = preload("res://characters/anchor.tscn")

@export var anchor_damage = 5
@export var anchor_fall_speed = -400.0

func _on_anchor_dropper_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	var anchor: Projectile = anchor_prefab.instantiate()
	anchor.global_position = global_position
	anchor.velocity = Vector2(0, 0)
	anchor.fall_speed = anchor_fall_speed
	anchor.damage = anchor_damage
	# TODO: inherit downwards momentum?
	
	var current_map = Globals.current_level
	current_map.add_child(anchor)
