class_name Player
extends CharacterBody2D

const AIR_ACCEL: float = 2500.0
const AIR_DECEL_MULT: float = 2.0
var SPEED: float = 150.0 # THIS USED TO BE CONST SO ITS UPPERCASE
const JUMP_VELOCITY: float = -150.0

var is_in_transition: bool = false
var is_dead: bool:
	get:
		return $Health.is_dead

var _slowdown_amount: float
var _push_force: Vector2 = Vector2.ZERO

enum Upgrade {
	UnlockHarpoonGun,
	UnlockNetThrower,
	UnlockAnchorDropper,
}

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
signal Heal

signal gained_upgrade(upgrade: Upgrade)


var is_moving: bool:
	get:
		return abs(velocity.x) > 0.5
		
var _jumping: bool = false
var is_crouching: bool = false

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

func _ready() -> void:
	Globals.player = self
	
	if Globals.tutorial_cleared:
		unlock_harpoon_gun()


func _physics_process(delta: float) -> void:
	if is_in_transition:
		return

	if is_on_floor():
		_jumping = false

	var direction = Input.get_axis("left", "right")
	if direction:
		looking_at = LookingAt.LEFT if direction < 0 else LookingAt.RIGHT

	if Input.is_action_pressed("crouch") and is_on_floor():
		is_crouching = true
		direction = 0.0
	else:
		is_crouching = false
	
	if direction and !is_dead:
		if is_on_floor():
			velocity.x = direction * SPEED * clamp(1.0 - _slowdown_amount, 0.0, 1.0)
		else:
			var speed = direction * SPEED * clamp(1.0 - _slowdown_amount, 0.0, 1.0)
			var accel = AIR_ACCEL * delta
			velocity.x = move_toward(velocity.x, speed, accel)
	else:
		var d = SPEED
		if not is_on_floor():
			d = AIR_DECEL_MULT * SPEED * delta
		velocity.x = move_toward(velocity.x, 0, d)
		
	# Dampen v velocities
	if velocity.y < JUMP_VELOCITY * 2.5:
		velocity.y = lerp(velocity.y, 0.0, 10.0 * delta)

	# Dampen high h velocities
	if abs(velocity.x) > JUMP_VELOCITY * 2.0:
		velocity.x = sign(velocity.x) * lerp(abs(velocity.x), 0.0, 10.0 * delta)

	# Always apply gravity to support gravity zones
	velocity += get_gravity() * delta
	if is_on_floor():
		velocity.y = min(velocity.y, 0.0) 

	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_dead:
		velocity.y = JUMP_VELOCITY
		_jumping = true
		$JumpTimer.start()
	
		Jumped.emit()

	if Input.is_action_pressed("jump") and _jumping and !is_on_floor():
		velocity.y = min(velocity.y, JUMP_VELOCITY)
		# HACK: small offset to mitigate gravity a bit
		velocity.y -= 200.0 * delta

	velocity += _push_force
	move_and_slide()

	# HACK: quickly diminish the push forces
	_push_force = _push_force.lerp(Vector2.ZERO, 0.5)


func _on_jump_timer_timeout() -> void:
	_jumping = false

func _input(event: InputEvent) -> void:
	if is_dead or is_in_transition:
		return
	
	var look_direction = Vector2(looking_at_scalar, 0.0)
	if event.is_action_pressed("attack_1"):
		$HarpoonGun.fire(self, look_direction)
	elif event.is_action_pressed("attack_2"):
		$NetThrower.fire(self, look_direction)
	elif event.is_action_pressed("attack_3"):
		$AnchorDropper.fire(self, look_direction)

func unlock_harpoon_gun():
	$HarpoonGun.is_unlocked = true
	gained_upgrade.emit(Upgrade.UnlockHarpoonGun)

func unlock_net_thrower():
	$NetThrower.is_unlocked = true
	gained_upgrade.emit(Upgrade.UnlockNetThrower)

func unlock_anchor_dropper():
	$AnchorDropper.is_unlocked = true
	gained_upgrade.emit(Upgrade.UnlockAnchorDropper)

func upgrade_harpoon_gun(tier: int):
	match tier:
		1:
			$HarpoonGun.cooldown = 0.25
			$HarpoonGun/HarpoonSpawner.projectile_damage = 2
		2:
			$HarpoonGun.cooldown = 0.1
			$HarpoonGun/HarpoonSpawner.projectile_damage = 3
		_:
			push_error("No tier %s implemented for harpoon gun upgrades" % tier)

func heal_to_full():
	$Health.heal(999, self)

func upgrade_max_health(tier: int):
	var amount = tier * 2
	$Health.max_health += amount
	$Health.heal(amount, self)

func upgrade_speed(tier: int):
	match tier:
		1:
			SPEED = 175
		2:
			SPEED = 200
		_:
			push_error("No speed upgrade tier %s implemented" % tier)

func get_health():
	return $Health._health

func get_max_health():
	return $Health.max_health

func _on_health_die() -> void:
	Die.emit()

	await UI.objective_overlay.show_objective("YOU", "ARE", "DEAD", 0.5)
	LevelRig.restart_game(true)

func _on_health_hurt() -> void:
	Hurt.emit()

func _on_health_heal() -> void:
	Heal.emit()
