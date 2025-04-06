class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

var is_in_transition: bool = false
var is_dead: bool:
	get:
		return $Health.is_dead

var _slowdown_amount: float
var _push_force: Vector2 = Vector2.ZERO

## Applies a knockback force (single time "impulse") on the player. 
func push(force: Vector2) -> void:
	_push_force += force

## Applies a movement slow on the player
func apply_slow(amount: float, duration: float) -> void:
	_slowdown_amount += amount
	await get_tree().create_timer(duration).timeout

	_slowdown_amount = move_toward(_slowdown_amount, 0, amount)


signal Jumped
signal Die
signal Hurt


var is_moving: bool:
	get:
		return abs(velocity.x) > 0.5

var looking_at: LookingAt = LookingAt.RIGHT
var looking_at_scalar: float:
	get:
		return Player.look_at_scalar(looking_at)
var looking_at_str: String:
	get:
		return Player.look_at_str(looking_at)

enum LookingAt {
	LEFT,
	RIGHT
}

static func look_at_scalar(direction: LookingAt) -> float:
	match direction:
		LookingAt.LEFT:
			return -1.0
		_:
			return 1.0

static func look_at_str(direction: LookingAt) -> String:
	match direction:
		LookingAt.LEFT:
			return "left"
		LookingAt.RIGHT:
			return "right"
		_:
			return "unknown"
			


func _physics_process(delta: float) -> void:
	if is_in_transition:
		return

	# Always apply gravity to support gravity zones
	velocity += get_gravity() * delta
	if is_on_floor():
		velocity.y = min(velocity.y, 0.0) 

	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_dead:
		velocity.y = JUMP_VELOCITY
		Jumped.emit()

	var direction = Input.get_axis("left", "right")
	if direction and !is_dead:
		velocity.x = direction * SPEED * clamp(1.0 - _slowdown_amount, 0.0, 1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_moving:
		looking_at = LookingAt.LEFT if velocity.x < 0 else LookingAt.RIGHT

	velocity += _push_force
	move_and_slide()

	# HACK: quickly diminish the push forces
	_push_force = _push_force.lerp(Vector2.ZERO, 0.5)

func _input(event: InputEvent) -> void:
	if is_dead or is_in_transition:
		return
	
	var look_direction = Vector2(looking_at_scalar, 0.0)
	if event.is_action_pressed("attack_1"):
		$HarpoonGun.fire(self, look_direction)
	elif event.is_action_pressed("attack_2"):
		$NetThrower.fire(self, look_direction)


func _on_health_die() -> void:
	Die.emit()

func _on_health_hurt() -> void:
	Hurt.emit()
