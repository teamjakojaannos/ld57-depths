extends Node2D

@export var min_speed = 0.0
@export var max_speed = 2.0
var speed = 0.0

var target = Vector2()

func _ready() -> void:
	rotation_degrees = randf_range(0, 360)
	target = Globals.current_level.get_random_fish_nav_point()
	speed = randf_range(min_speed, max_speed)

func _physics_process(delta: float) -> void:
	position = position.move_toward(target, delta * speed)

func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$HurtAnimations.stop()
	$HurtAnimations.play("hurt")

func _on_health_die() -> void:
	Globals.level.current_level.record_kill()
	$HurtAnimations.play("die")
	await $HurtAnimations.animation_finished
	queue_free()
