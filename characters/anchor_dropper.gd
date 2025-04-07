extends Marker2D

const anchor_prefab = preload("res://characters/anchor.tscn")

@export var anchor_damage = 5
@export var anchor_fall_speed = -400.0

func _on_anchor_dropper_fire(shooter: CharacterBody2D, _direction: Vector2) -> void:
	var anchor: Projectile = anchor_prefab.instantiate()
	anchor.global_position = global_position
	
	# anchor inherits downwards velocity of the shooter
	var inherited_speed = max(0.0, shooter.velocity.y * 1.3333)
	anchor.velocity = Vector2(0, inherited_speed)
	
	if shooter is Player:
		shooter.push(Vector2.UP * -anchor_fall_speed * 0.2)
	
	anchor.fall_speed = anchor_fall_speed + inherited_speed
	anchor.damage = anchor_damage
	
	var current_map = Globals.current_level
	current_map.add_child(anchor)
