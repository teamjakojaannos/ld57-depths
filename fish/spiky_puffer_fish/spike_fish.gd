extends Area2D

const spike_scene = preload("res://fish/spiky_puffer_fish/spike.tscn")
@export var spike_speed = 100.0

func _do_attack() -> void:
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
