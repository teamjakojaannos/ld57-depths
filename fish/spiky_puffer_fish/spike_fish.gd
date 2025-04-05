extends Area2D

const spike_scene = preload("res://fish/spiky_puffer_fish/spike.tscn")
@export var spike_speed = 100.0

var ready_to_attack: bool = false
@export var min_attack_cooldown = 5.0
@export var max_attack_cooldown = 10.0

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
	
	var spawns = $SpikeSpawns.get_children()
	var origin: Vector2 = $SpikeOrigin.global_position
	
	for spawn in spawns:
		var spike: Spike = spike_scene.instantiate()
		var velocity = (spawn.global_position - origin).normalized() * spike_speed
		var angle = origin.angle_to_point(spawn.global_position)
		angle += PI / 2.0
		
		spike.velocity = velocity
		spike.global_position = spawn.global_position
		spike.rotation = angle
		
		parent.add_child(spike)
