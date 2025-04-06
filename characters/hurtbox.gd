@tool
extends Area2D
class_name Hurtbox

signal hurt_target(other: Hitbox)

@export var damage: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area2D) -> void:
	# Hit something with health => damage
	if other is Hitbox and not other.health.is_dead:
		# FIXME: there should be a reference to the shooter/real source
		#        here in the projectile to figure out who damaged whom
		other.health.take_damage_at(damage, self, global_position)

		hurt_target.emit(other)
