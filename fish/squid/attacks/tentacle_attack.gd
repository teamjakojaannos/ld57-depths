extends SquidAttack

const tentacle_prefab: PackedScene = preload("res://fish/squid/tentacle.tscn")

@export var wait_time_before_attack = 0.5
@export var tentacle_speed = 400.0
@export var tentacle_damage = 1

func do_attack(level: SquidFightLevel):
	var positions = level.get_random_tentacle_spawn()
	var tentacle: Tentacle = tentacle_prefab.instantiate()
	
	
	# get pos relative to level
	var spawn_position = positions.spawn.position + positions.position
	var end_position = positions.end.position + positions.position
	
	tentacle.damage = tentacle_damage
	tentacle.max_speed = tentacle_speed
	tentacle.initial_speed = tentacle_speed / 4.0
	tentacle.speed_up_time = 0.5
	tentacle.wait_time_before_attack = wait_time_before_attack
	tentacle.position = spawn_position
	tentacle.start_pos = spawn_position
	tentacle.end_pos = end_position
	tentacle.set_flipped(!positions.is_left_to_right)
	tentacle.visible = false
	
	level.add_child(tentacle)
	
	await tentacle.attack_done
	squid_attack_done.emit()
