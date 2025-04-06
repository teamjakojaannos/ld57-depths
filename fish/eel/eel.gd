extends Area2D

@export var damage = 1

var entities_inside_area = {}

func _on_area_entered(other: Area2D) -> void:
	if other is Hitbox:
		# no hashsets in gdscript -> use dictionary with null value
		entities_inside_area.set(other, null)

func _on_area_exited(other: Area2D) -> void:
	if other is Hitbox:
		entities_inside_area.erase(other)

func _damage_entities() -> void:
	for hitbox: Hitbox in entities_inside_area.keys():
		hitbox.health.take_damage(damage, self)

func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hurt")

func _on_health_die() -> void:
	Globals.level.current_level.record_kill()

	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()
