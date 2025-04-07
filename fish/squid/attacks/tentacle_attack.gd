extends SquidAttack

const tentacle_prefab: PackedScene = preload("res://fish/squid/tentacle.tscn")

@export var tentacle_speed = 100.0
@export var tentacle_damage = 1

func do_attack(level: SquidFightLevel):
	var positions = level.get_random_tentacle_spawn()
	var tentacle: Tentacle = tentacle_prefab.instantiate()
	
	tentacle.damage = tentacle_damage
	tentacle.speed = tentacle_speed
	tentacle.position = positions.spawn.position
	tentacle.start_pos = positions.spawn.position
	tentacle.end_pos = positions.end.position
	level.add_child(tentacle)
	
	await tentacle.attack_done
	squid_attack_done.emit()
