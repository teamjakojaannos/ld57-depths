extends PathFollow2D

@export var move_speed = 10.0
var move_direction: int = 1

@onready var sprite: Node2D = $Sprite
@onready var hurtbox: Hurtbox = Nodes.find_by_class(self, Hurtbox)
@onready var hitbox: Hitbox = Nodes.find_by_class(self, Hitbox)

func _ready() -> void:
	progress_ratio = randf()
	var moves_forward = randi_range(0, 1) == 0
	move_direction = 1 if moves_forward else -1

	$CrabRoot/Hurtbox.enabled = false
	_do_spawn.call_deferred()

func _do_spawn() -> void:
	$SpawnAnimation.play("spawn")
	await $SpawnAnimation.animation_finished
	$CrabRoot/Hurtbox.enabled = false

func _physics_process(delta: float) -> void:
	if $Health.is_dead:
		return

	progress += move_speed * move_direction * delta


func _on_health_die() -> void:
	# Prevent getting hit or dealing damage once dead
	hurtbox.queue_free()
	hitbox.queue_free()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "global_position", sprite.global_position + Vector2.DOWN * 100.0, 1.5)
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 1.5)
	await tween.finished
	queue_free()
