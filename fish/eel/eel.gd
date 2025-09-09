extends Node2D

@export var damage = 1
@export var speed = 150.0

@export var level_bound_left = -200
@export var level_bound_right = 200

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animations: AnimationPlayer = $Animations
@onready var health: Health = Health.find(self)

var _facing: Facing.Horizontal = Facing.Horizontal.LEFT

func _physics_process(delta: float) -> void:
	var is_moving_left = _facing == Facing.Horizontal.LEFT
	var is_moving_right = _facing == Facing.Horizontal.RIGHT

	var min_bound = min(level_bound_left, level_bound_right)
	var max_bound = max(level_bound_left, level_bound_right)
	var is_over_bounds: bool = \
		(position.x >= max_bound and is_moving_right) or \
		(position.x <= min_bound and is_moving_left)

	if is_over_bounds:
		_facing = Facing.opposite_h(_facing)

	var direction = Facing.as_vec_h(_facing)
	var velocity = direction * speed
	position = position + velocity * delta

	sprite.flip_h = is_moving_right


func _on_health_die() -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed", 0.0, 1.0)

	animations.play("die")
	await animations.animation_finished
	queue_free()
