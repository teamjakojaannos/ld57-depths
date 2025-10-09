@tool
class_name Eel
extends Node2D

enum InitialFacing { LEFT, RIGHT, RANDOM }

@export var speed = 150.0
@export var damage: float = 1:
	get:
		return Exports.delegate_get(hurtbox, "damage", 1)
	set(value):
		Exports.delegate_set(hurtbox, "damage", value)
@export var max_health: float = 5:
	get:
		return Exports.delegate_get(health, "max_health", 5)
	set(value):
		Exports.delegate_set(health, "max_health", value)
@export var initial_facing: InitialFacing = InitialFacing.RANDOM:
	get:
		return initial_facing
	set(value):
		initial_facing = value
		_facing = _to_facing(value)

var _facing: Facing.Horizontal = Facing.Horizontal.LEFT:
	get:
		return _facing
	set(value):
		_facing = value
		_refresh_sprite.call_deferred()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animations: AnimationPlayer = $Animations
@onready var health: Health = Nodes.find_by_class(self, Health)
@onready var hurtbox: Hurtbox = Nodes.find_by_class(self, Hurtbox)


static func _to_facing(initial: InitialFacing) -> Facing.Horizontal:
	match initial:
		InitialFacing.LEFT:
			return Facing.Horizontal.LEFT
		InitialFacing.RIGHT:
			return Facing.Horizontal.RIGHT
		# InitialFacing.RANDOM
		_:
			if randf() < 0.5:
				return Facing.Horizontal.LEFT
			else:
				return Facing.Horizontal.RIGHT


func _ready() -> void:
	_facing = _to_facing(initial_facing)
	_refresh_sprite()

	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
		return


func _physics_process(delta: float) -> void:
	var direction = Facing.as_vec_h(_facing)
	var velocity = direction * speed
	position = position + velocity * delta


func _on_health_die() -> void:
	if Engine.is_editor_hint():
		return

	hurtbox.queue_free()

	var tween = create_tween()
	tween.tween_property(self, "speed", 0.0, 1.0)

	animations.play("die")
	await animations.animation_finished
	queue_free()


func _refresh_sprite() -> void:
	var is_moving_right = _facing == Facing.Horizontal.RIGHT
	sprite.flip_h = is_moving_right
