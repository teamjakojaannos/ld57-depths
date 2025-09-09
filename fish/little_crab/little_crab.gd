extends PathFollow2D

@export var move_speed = 10.0
var move_direction: int = 1

@onready var sprite: Node2D = $Sprite
@onready var hurtbox: Hurtbox = Nodes.find_by_class(self, Hurtbox)

func _ready() -> void:
	progress_ratio = randf()
	var moves_forward = randi_range(0, 1) == 0
	move_direction = 1 if moves_forward else -1

func _physics_process(delta: float) -> void:
	if $Health.is_dead:
		return

	progress += move_speed * move_direction * delta


func _on_health_die() -> void:
	hurtbox.queue_free()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "global_position", sprite.global_position + Vector2.DOWN * 100.0, 1.5)
	tween.tween_property(sprite, "modulate", Color.TRANSPARENT, 1.5)
	await tween.finished
	queue_free()
