extends SquidAttack

const tentacle_prefab: PackedScene = preload("res://fish/squid/tentacle.tscn")

@export var wait_time_before_attack = 1.5
@export var tentacle_speed = 400.0
@export var tentacle_damage = 1

var tentacles = []
var tentacles_extended = 0
var attacks_done = 0

func do_attack(level: SquidFightLevel):
	var positions = level.get_tentacle_sequence_positions()
	var i = 0
	
	if !tentacles.is_empty():
		# shouldn't be needed but just in case I have written buggy code
		clear_tentacles()
	
	tentacles.clear()
	tentacles_extended = 0
	attacks_done = 0
	
	for pos in positions:
		var tentacle = spawn_tentacle(level, pos, i * wait_time_before_attack)
		tentacle.fully_extended.connect(tentacle_extended)
		tentacle.attack_done.connect(tentacle_attack_done)
		tentacles.append(tentacle)
		i += 1
	
	squid_attack_done.emit()

func tentacle_extended():
	tentacles_extended += 1
	if tentacles_extended >= tentacles.size():
		await get_tree().create_timer(1.0).timeout
		# all extended, start reversing
		for tentacle in tentacles:
			tentacle._going_forward = false

func tentacle_attack_done():
	attacks_done += 1
	if attacks_done >= tentacles.size():
		tentacles.clear()
		squid_attack_done.emit()

func spawn_tentacle(level: SquidFightLevel, positions: TentacleMarkers, wait_time: float) -> Tentacle:
	var tentacle: Tentacle = tentacle_prefab.instantiate()
	
	# get pos relative to level
	var spawn_position = positions.spawn.position + positions.position
	var end_position = positions.end.position + positions.position
	
	tentacle.reverse_after_fully_extended = false
	tentacle.damage = tentacle_damage
	tentacle.max_speed = tentacle_speed
	tentacle.initial_speed = tentacle_speed / 4.0
	tentacle.speed_up_time = 0.5
	tentacle.wait_time_before_attack = wait_time
	tentacle.position = spawn_position
	tentacle.start_pos = spawn_position
	tentacle.end_pos = end_position
	tentacle.set_flipped(!positions.is_left_to_right)
	tentacle.visible = false
	
	level.add_child(tentacle)
	
	return tentacle

func clear_tentacles():
	for t in tentacles:
		t.queue_free()
