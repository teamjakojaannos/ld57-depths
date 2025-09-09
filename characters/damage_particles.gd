@tool
extends Node2D
class_name DamageParticles

@export var particle_emitter: PackedScene = preload("uid://dkgpgoo61sytr")

@export_group("Advanced")
@export var health: Health

func _ready() -> void:
	health = Nodes.find_if_null(get_parent(), health, Health)

	if not Objects.is_null(health):
		Signals.try_connect(health.hurt_at, _on_health_hurt_at)

func _on_health_hurt_at(pos: Vector2):
	var emitter: Node2D = particle_emitter.instantiate()
	emitter.global_position = pos
	Globals.current_room.add_child(emitter)
