@tool
extends Node2D
class_name DamageParticles

@export var particle_emitter: PackedScene

@export_group("Advanced")
@export var health: Health

func _ready() -> void:
	Components.set_default_sibling(self, "health", "Health")
	Components.try_connect_to(health, "hurt_at", _on_health_hurt_at)

func _on_health_hurt_at(pos: Vector2):
	var emitter: Node2D = particle_emitter.instantiate()
	emitter.global_position = pos
	Globals.current_room.add_child(emitter)
