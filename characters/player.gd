class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@export var max_hp = 10
var hp = max_hp

var is_in_transition: bool = false
var is_dead: bool = false

const harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
var is_harpoon_ready = true
@export var harpoon_cooldown = 0.75

const net_attack_prefab = preload("res://characters/net_projectile.tscn")
var is_net_attack_ready = true
@export var net_attack_cooldown = 0.75
@export var net_flying_speed = 75.0

func _physics_process(delta: float) -> void:
	if is_in_transition:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_dead:
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction and !is_dead:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_1"):
		do_harpoon_attack()
	elif event.is_action_pressed("attack_2"):
		do_net_attack()

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
	else:
		$AnimationPlayer.play("take_damage")

func die():
	if is_dead:
		return
	is_dead = true
	$AnimationPlayer.play("die")

func do_harpoon_attack():
	if !is_harpoon_ready or is_in_transition or is_dead:
		return
	
	var projectile: HarpoonProjectile = harpoon_scene.instantiate()
	projectile.global_position = $HarpoonSpawn.global_position
	var current_map = get_current_map()
	if current_map == null:
		printerr("Can't find map where to spawn projectiles")
		return
	current_map.add_child(projectile)
	
	is_harpoon_ready = false
	await get_tree().create_timer(harpoon_cooldown).timeout
	is_harpoon_ready = true

func do_net_attack():
	if !is_net_attack_ready or is_in_transition or is_dead:
		return

	var current_map = get_current_map()
	if current_map == null:
		printerr("Can't find map where to spawn nets")
		return

	var net: NetProjectile = net_attack_prefab.instantiate()
	net.global_position = $NetSpawn.global_position
	var velocity = ($NetThrowDirection.global_position - $NetSpawn.global_position).normalized() * net_flying_speed
	net.initial_velocity = velocity
	current_map.add_child(net)

	is_net_attack_ready = false
	await get_tree().create_timer(net_attack_cooldown).timeout
	is_net_attack_ready = true

func get_current_map():
	var level = get_node_or_null("../EndlessLevel")
	if level == null or level is not EndlessLevel:
		return null
	
	return level.current_level
