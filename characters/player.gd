class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@export var max_hp = 10
var hp = max_hp

var is_in_transition: bool = false

var harpoon_scene = preload("res://characters/harpoon_projectile.tscn")
var is_harpoon_ready = true
@export var harpoon_cooldown = 0.75

func _physics_process(delta: float) -> void:
	if is_in_transition:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_1"):
		do_harpoon_attack()

func take_damage(amount: int):
	hp -= amount
	print("Ouch, my hp is: ", hp)
	$AnimationPlayer.play("take_damage")

func do_harpoon_attack():
	if !is_harpoon_ready:
		return
	
	var projectile: HarpoonProjectile = harpoon_scene.instantiate()
	projectile.global_position = $HarpoonSpawn.global_position
	get_parent().add_child(projectile)
	
	is_harpoon_ready = false
	await get_tree().create_timer(harpoon_cooldown).timeout
	is_harpoon_ready = true
