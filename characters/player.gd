class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@export var max_hp = 10
var hp = max_hp

var is_in_transition: bool = false
var is_dead: bool = false

const net_attack_prefab = preload("res://characters/net_projectile.tscn")
var is_net_attack_ready = true
@export var net_attack_cooldown = 0.75
@export var net_flying_speed = 200.0
@export var net_fall_speed = -200.0

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
signal Died
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

	if not is_on_floor():
		velocity += get_gravity() * delta

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
	
	if event.is_action_pressed("attack_1"):
		$Gun.do_harpoon_attack()
	elif event.is_action_pressed("attack_2"):
		do_net_attack()

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
	else:
		Hurt.emit()

func die():
	if is_dead:
		return
	is_dead = true

	Died.emit()


func do_net_attack():
	if !is_net_attack_ready or is_in_transition or is_dead:
		return

	var current_map = get_current_map()
	if current_map == null:
		printerr("Can't find map where to spawn nets")
		return

	var net: NetProjectile = net_attack_prefab.instantiate()
	net.global_position = $NetSpawn.global_position
	var net_velocity = ($NetThrowDirection.global_position - $NetSpawn.global_position).normalized() * net_flying_speed
	net.velocity = net_velocity
	net.fall_speed = net_fall_speed
	current_map.add_child(net)

	is_net_attack_ready = false
	await get_tree().create_timer(net_attack_cooldown).timeout
	is_net_attack_ready = true

func get_current_map():
	var level = get_node_or_null("../EndlessLevel")
	if level == null or level is not EndlessLevel:
		return null
	
	return level.current_level
