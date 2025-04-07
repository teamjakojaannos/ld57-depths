class_name Tentacle
extends Node2D

var damage: float:
	set(value):
		$Hurtbox.damage = value
var speed_up_time: float = 1.0
var initial_speed: float
var max_speed: float
var start_pos: Vector2
var end_pos: Vector2
var wait_time_before_attack: float = 1.0
var reverse_after_fully_extended = true
var _going_forward = true
var _can_move = false
var _speed: float
var signal_emitted_fully_extended = false
var signal_emitted_attack_done = false

signal attack_done
signal fully_extended

func _ready() -> void:
	$AnimationPlayer.play("emerge")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(wait_time_before_attack).timeout
	_can_move = true
	_speed = initial_speed
	var speed_tween = create_tween()
	speed_tween.tween_property(self, "_speed", max_speed, speed_up_time)

func set_flipped(flipped: bool):
	scale = Vector2(-1, 1) if flipped else Vector2(1, 1)

func _physics_process(delta: float) -> void:
	if !_can_move:
		return
	
	var close_enough = 20.0
	
	var target = end_pos if _going_forward else start_pos
	
	position = position.move_toward(target, delta * _speed)
	
	if position.distance_squared_to(target) <= close_enough:
		if _going_forward:
			if !signal_emitted_fully_extended:
				signal_emitted_fully_extended = true
				fully_extended.emit()
			if reverse_after_fully_extended:
				_going_forward = false
		else:
			_attack_done()

func _attack_done():
	if !signal_emitted_attack_done:
		signal_emitted_attack_done = true
		attack_done.emit()
	$AnimationPlayer.play_backwards("emerge")
	await $AnimationPlayer.animation_finished
	queue_free()
