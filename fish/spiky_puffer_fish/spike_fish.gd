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

func _ready() -> void:
	# get some variation so fishes don't instantly attack on entering new level
	start_attack_cooldown(0.0, max_attack_cooldown)

func _physics_process(_delta: float) -> void:
	if ready_to_attack:
		attack()

func attack():
	ready_to_attack = false
	$AnimationPlayer.play("attack")
	await $AnimationPlayer.animation_finished
	start_attack_cooldown(min_attack_cooldown, max_attack_cooldown)

func start_attack_cooldown(min_cd: float, max_cd: float):
	var attack_cooldown = randf_range(min_cd, max_cd)
	await get_tree().create_timer(attack_cooldown).timeout
	ready_to_attack = true

func _shoot_spikes() -> void:
	var parent = get_parent()

	var zero = Vector2(0, 0)
	var spike_count = randi_range(min_spike_count, max_spike_count)

	for _s in spike_count:
		var spawn = point_on_unit_circle()
		var velocity = spawn * randf_range(min_spike_speed, max_spike_speed)
		var angle = zero.angle_to_point(spawn)
		angle += PI / 2.0
		
		var spike: Spike = spike_scene.instantiate()
		spike.velocity = velocity
		spike.global_position = $SpikeOrigin.global_position + spawn
		spike.rotation = angle
		
		parent.add_child(spike)

func take_damage(amount: int):
	print("fish took some damage")

func point_on_unit_circle() -> Vector2:
	var angle = randf() * 2.0 * PI
	var x = cos(angle)
	var y = sin(angle)
	return Vector2(x, y)
