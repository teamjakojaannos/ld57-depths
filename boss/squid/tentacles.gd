extends Node2D


func left_side() -> Array[BossTentacle]:
	return [$Tentacle6, $Tentacle8]
	
func right_side() -> Array[BossTentacle]:
	return [$Tentacle5, $Tentacle7]
	
func bottom() -> Array[BossTentacle]:
	return [$Tentacle, $Tentacle2, $Tentacle3, $Tentacle4]

func attack_force_crouch() -> void:
	var tents = left_side()
	tents.shuffle()
	await _attack_wave(tents, 1.0, 1.5, 2.5, 2.5)

func attack_force_middle() -> void:
	var tents = right_side()
	tents.shuffle()
	await _attack_wave(tents, 1.0, 1.5, 2.5, 2.5)

func attack_vertical(indices: Array) -> void:
	var all = bottom()
	var tents = []
	for idx in indices:
		tents.push_back(all[idx])

	await _attack_wave(tents, 0.5, 1.5, 1.5, 1.5)

func retract_all() -> void:
	for t in left_side():
		t.stop()
	for t in right_side():
		t.stop()
	for t in bottom():
		t.stop()
		

func _attack_wave(
	tents: Array,
	min_delay: float,
	max_delay: float,
	min_wait: float,
	max_wait: float
) -> void:
	for t in tents:
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
		t.peek()

	await get_tree().create_timer(randf_range(min_wait, max_wait)).timeout

	for t in tents:
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
		t.attack()
	
	await get_tree().create_timer(randf_range(min_wait, max_wait)).timeout
	
	for t in tents:
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
		t.retract()
	
	# HACK: wait for a bit to give time for animations to finish
	await get_tree().create_timer(1.0).timeout
