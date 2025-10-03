extends Node2D

enum InitialFacing {LEFT, RIGHT, RANDOM}

@export var damage = 1
@export var speed = 150.0

@export var level_bound_left = -320
@export var level_bound_right = 320

@export var target: Node2D
@export var initial_facing: InitialFacing = InitialFacing.RANDOM

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animations: AnimationPlayer = $Animations
@onready var health: Health = Nodes.find_by_class(self, Health)
@onready var hurtbox: Hurtbox = Nodes.find_by_class(self, Hurtbox)

var _facing: Facing.Horizontal = Facing.Horizontal.LEFT

func _ready() -> void:
	match initial_facing:
		InitialFacing.LEFT:
			_facing = Facing.Horizontal.LEFT
		InitialFacing.RIGHT:
			_facing = Facing.Horizontal.RIGHT
		InitialFacing.RANDOM:
			if randf() < 0.5:
				_facing = Facing.Horizontal.LEFT
			else:
				_facing = Facing.Horizontal.RIGHT

	_start_spawn_sequence.call_deferred()


func _process(_delta: float) -> void:
	var is_moving_right = _facing == Facing.Horizontal.RIGHT
	sprite.flip_h = is_moving_right


func _physics_process(delta: float) -> void:
	var direction = Facing.as_vec_h(_facing)
	var velocity = direction * speed
	position = position + velocity * delta


func _on_health_die() -> void:
	hurtbox.queue_free()

	var tween = create_tween()
	tween.tween_property(self, "speed", 0.0, 1.0)

	animations.play("die")
	await animations.animation_finished
	queue_free()


func _on_screen_exited() -> void:
	await get_tree().create_timer(1.0, false).timeout
	_start_spawn_sequence.call_deferred()


func _start_spawn_sequence() -> void:
	if not _pick_target():
		push_warning("Could not pick target!")
		return

	if _facing == Facing.Horizontal.LEFT:
		global_position.x = level_bound_left
	else:
		global_position.x = level_bound_right

	global_position.y = target.global_position.y
	_facing = Facing.opposite_h(_facing)


func _pick_target() -> bool:
	if target == null:
		if Globals.player == null:
			return false

		target = Globals.player

	return true
