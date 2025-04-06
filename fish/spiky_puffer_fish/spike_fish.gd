class_name SpikeFish
extends Area2D

const spike_scene = preload("res://fish/spiky_puffer_fish/spike.tscn")
@export var min_spike_speed = 100.0
@export var max_spike_speed = 200.0

var ready_to_attack: bool = false
@export var min_attack_cooldown = 5.0
@export var max_attack_cooldown = 10.0

@export var min_spike_count = 3
@export var max_spike_count = 8

@export var move_speed = 50.0

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

func _physics_process(delta: float) -> void:
	var target_position = (target1 + target1) / 2.0
	var previous_position = position
	position = position.move_toward(target_position, move_speed * delta)
	
	var movement = position - previous_position
	$AnimatedSprite2D.flip_h = movement.x > 0
	
	var d2 = position.distance_squared_to(target_position)
	var close_enough = 10.0
	if d2 <= close_enough:
		_create_movement_tweens(true)

	if ready_to_attack and !is_dead:
		attack()

func attack():
	ready_to_attack = false
	$AttackAnimationPlayer.play("attack")
	await $AttackAnimationPlayer.animation_finished
	start_attack_cooldown(min_attack_cooldown, max_attack_cooldown)

func start_attack_cooldown(min_cd: float, max_cd: float):
	var attack_cooldown = randf_range(min_cd, max_cd)
	await get_tree().create_timer(attack_cooldown).timeout
	ready_to_attack = true

func _shoot_spikes() -> void:
	if is_dead:
		return

	var parent = get_parent()

	var zero = Vector2(0, 0)
	var spike_count = randi_range(min_spike_count, max_spike_count)

	for _s in spike_count:
		var spawn = point_on_unit_circle()
		var velocity = spawn * randf_range(min_spike_speed, max_spike_speed)
		
		var spike: Projectile = spike_scene.instantiate()
		spike.velocity = velocity
		spike.global_position = $SpikeOrigin.global_position + spawn
		
		Globals.level.current_level.add_child(spike)


func pick_random_target_position() -> Vector2:
	var current_level = get_parent()
	if current_level == null:
		return position
	
	var nav_area: CollisionShape2D = current_level.get_node_or_null("FishNavArea/Shape")
	if nav_area == null:
		return position
	
	var rect : Rect2 = nav_area.shape.get_rect()
	var x = randf_range(-rect.size.x, rect.size.x) / 2.0
	var y = randf_range(-rect.size.y, rect.size.y) / 2.0
	return Vector2(x, y) + nav_area.position

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
	Globals.level.current_level.record_kill()

	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()
