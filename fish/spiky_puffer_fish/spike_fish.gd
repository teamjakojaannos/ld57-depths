class_name SpikeFish
extends Area2D

const spike_scene = preload("res://fish/spiky_puffer_fish/spike.tscn")
@export var spike_color: Color = Color(1, 1, 1, 1)
@export var spike_damage = 1
@export var min_spike_speed = 100.0
@export var max_spike_speed = 200.0

var ready_to_attack: bool = false
@export var min_attack_cooldown = 5.0
@export var max_attack_cooldown = 10.0

@export var min_spike_count = 3
@export var max_spike_count = 8

@export var normal_move_speed = 50.0
@export var attack_move_speed = 5.0
var move_speed = normal_move_speed

var is_dead: bool:
	get:
		return $Health.is_dead

var movement_tween_1: Tween
var movement_tween_2: Tween
var target1: Vector2 = Vector2()
var target2: Vector2 = Vector2()

func _ready() -> void:
	# get some variation so fishes don't instantly attack on entering new level
	start_attack_cooldown(0.0, max_attack_cooldown)

	target1 = position
	target2 = position
	_create_movement_tweens()

func _create_movement_tweens(force_recreate: bool = false):
	var is_tween1_ok = movement_tween_1 != null && movement_tween_1.is_running()
	var is_tween2_ok = movement_tween_2 != null && movement_tween_2.is_running()

	if !is_tween1_ok || force_recreate:
		if movement_tween_1 != null:
			movement_tween_1.kill()

		var end = pick_random_target_position()
		var time = randf_range(1.0, 2.0)

		movement_tween_1 = create_tween()
		movement_tween_1.tween_property(self, "target1", end, time)
		movement_tween_1.tween_callback(_create_movement_tweens)

	if !is_tween2_ok || force_recreate:
		if movement_tween_2 != null:
			movement_tween_2.kill()

		var end = pick_random_target_position()
		var time = randf_range(1.0, 2.0)

		movement_tween_2 = create_tween()
		movement_tween_2.tween_property(self, "target2", end, time)
		movement_tween_2.tween_callback(_create_movement_tweens)

var last_direction: Vector2 = Vector2.RIGHT
func _physics_process(delta: float) -> void:
	var target_position = (target1 + target2) / 2.0
	var previous_position = position

	var d2 = position.distance_squared_to(target_position)
	var close_enough = 500.0
	if d2 <= close_enough:
		if _is_allowed_to_stop():
			return
		else:
			position += last_direction * move_speed * delta
	else:
		position = position.move_toward(target_position, move_speed * delta)
		last_direction = (position - previous_position).normalized()

	var movement = position - previous_position
	$AnimatedSprite2D.flip_h = movement.x > 0

	if ready_to_attack and !is_dead:
		if _is_allowed_to_stop():
			attack()

func _is_allowed_to_stop():
	return Globals.current_room.is_in_navigable_region(global_position)


func attack():
	ready_to_attack = false
	var tween = create_tween()
	tween.tween_property(self, "move_speed", attack_move_speed, 0.5)

	$AttackAnimationPlayer.play("attack")
	await $AttackAnimationPlayer.animation_finished

	tween.kill()
	move_speed = normal_move_speed

	start_attack_cooldown(min_attack_cooldown, max_attack_cooldown)

func start_attack_cooldown(min_cd: float, max_cd: float):
	var attack_cooldown = randf_range(min_cd, max_cd)
	await get_tree().create_timer(attack_cooldown).timeout
	ready_to_attack = true

func _shoot_spikes() -> void:
	if is_dead:
		return

	var spike_count = randi_range(min_spike_count, max_spike_count)

	var angle_per_spike = (2 * PI) / spike_count
	var max_angle_variation = angle_per_spike / 2.5

	var start_angle = randf() * 2 * PI
	for i in spike_count:
		var angle = start_angle + angle_per_spike * i
		var variation = randf() * max_angle_variation

		var direction = Vector2.from_angle(angle + variation)
		var velocity = direction * randf_range(min_spike_speed, max_spike_speed)

		var spike: Projectile = spike_scene.instantiate()
		spike.modulate = spike_color
		spike.velocity = velocity
		spike.global_position = $SpikeOrigin.global_position + direction
		spike.damage = spike_damage

		Globals.current_room.add_child(spike)


func pick_random_target_position() -> Vector2:
	var current_room = Globals.current_room
	if current_room == null:
		return position

	var player = Globals.player
	if player == null:
		return current_room.get_random_fish_nav_point()

	var tries = 0
	while (tries < 50):
		tries += 1

		var dx = 4 * 32
		var dy = 3 * 32
		var x = randf_range(-dx, dx)
		var y = randf_range(-8, dy - 8)

		var point = player.global_position + Vector2(y, x)
		if current_room.is_in_navigable_region(point):
			return point

	return position

func point_on_unit_circle() -> Vector2:
	var angle = randf() * 2.0 * PI
	var x = cos(angle)
	var y = sin(angle)
	return Vector2(x, y)


func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hurt")


func _on_health_die() -> void:
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()
