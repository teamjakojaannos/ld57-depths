@tool
extends Node2D
class_name DamageParticles

@export var particle_emitter: PackedScene

@export var health: Health


func _ready() -> void:
	if health == null:
		health = get_parent().get_node_or_null("Health")

	if health is Health:
		if not health.hurt_at.is_connected(_on_health_hurt_at):
			health.hurt_at.connect(_on_health_hurt_at)

func _on_health_hurt_at(pos: Vector2):
	var emitter: Node2D = particle_emitter.instantiate()
	emitter.global_position = pos
	Globals.current_room.add_child(emitter)
