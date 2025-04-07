class_name Tentacle
extends Node2D

var damage: float:
	set(value):
		$Hurtbox.damage = value
var speed: float
var start_pos: Vector2
var end_pos: Vector2
var _going_forward = true

signal attack_done

func set_flipped(flipped: bool):
	scale = Vector2(-1, 1) if flipped else Vector2(1, 1)

func _physics_process(delta: float) -> void:
	var close_enough = 20.0
	
	var target = end_pos if _going_forward else start_pos
	
	position = position.move_toward(target, delta * speed)
	
	if position.distance_squared_to(target) <= close_enough:
		if _going_forward:
			_going_forward = false
		else:
			_attack_done()

func _attack_done():
	attack_done.emit()
	queue_free()
