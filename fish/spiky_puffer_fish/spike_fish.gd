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

var target_position: Vector2 = Vector2()

func _ready() -> void:
	# get some variation so fishes don't instantly attack on entering new level
	start_attack_cooldown(0.0, max_attack_cooldown)

	_create_movement_tween()

func set_target_position(vec: Vector2):
	target_position = vec

func _create_movement_tween():
	var r1 = pick_random_target_position()
	var r2 = pick_random_target_position()
	var t1 = create_tween()
	t1.tween_method(set_target_position, r1, r2, 1.5)
	t1.tween_callback(_create_movement_tween)

func _physics_process(delta: float) -> void:
	position = position.move_toward(target_position, move_speed * delta)

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


func pick_random_target_position() ->Vector2:
	var current_level = get_parent()
	if current_level == null:
		return Vector2()
	
	var nav_points = current_level.get_node_or_null("FishNavPoints")
	if nav_points == null:
		return Vector2()
	
	var markers = nav_points.get_children()
	if markers.size() == 0:
		return Vector2()
	
	return markers.pick_random().position

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
