class_name Player
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@export var max_hp = 10
var hp = max_hp


func _physics_process(delta: float) -> void:
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

func take_damage(amount: int):
	hp -= amount
	print("Ouch, my hp is: ", hp)
	$AnimationPlayer.play("take_damage")
