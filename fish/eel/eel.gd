extends Area2D

@export var damage = 1
@export var speed = 150.0

enum Direction {
	Left, Right
}

var move_direction = Direction.Left
var level_bound_left = -200
var level_bound_right = 200

var entities_inside_area = {}

func _physics_process(delta: float) -> void:
	var close_enough = 20.0
	var go_right = move_direction == Direction.Right
	var is_over_bounds = position.x >= level_bound_right if go_right else position.x <= level_bound_left
	if is_over_bounds:
		move_direction = Direction.Left if go_right else Direction.Right
	
	var direction = Vector2(1.0, 0.0) if go_right else Vector2(-1.0, 0.0)
	position = position + direction * speed * delta
	
	$AnimatedSprite2D.flip_h = go_right

func _on_area_entered(other: Area2D) -> void:
	if other is Hitbox:
		# no hashsets in gdscript -> use dictionary with null value
		entities_inside_area.set(other, null)

func _on_area_exited(other: Area2D) -> void:
	if other is Hitbox:
		entities_inside_area.erase(other)

func _damage_entities() -> void:
	if $Health.is_dead:
		return
	
	for hitbox: Hitbox in entities_inside_area.keys():
		hitbox.health.take_damage(damage, self)

func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$HurtAnimations.stop()
	$HurtAnimations.play("hurt")

func _on_health_die() -> void:
	Globals.level.current_level.record_kill()

	$HurtAnimations.play("die")
	await $HurtAnimations.animation_finished
	queue_free()
