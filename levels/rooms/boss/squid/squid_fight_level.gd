class_name SquidFightLevel
extends Node2D


func _on_h_attack_timer_timeout() -> void:
	if randf() < 0.5:
		# HACK: delay vertical attacks to make unwinnable situations more unlikely
		$VAttackTimer.wait_time += 2.0
		await $Tentacles.attack_force_crouch()
	else:
		await $Tentacles.attack_force_middle()

	$HAttackTimer.wait_time = randf_range(
		3.0,
		5.0
	)
	$HAttackTimer.start()


func _on_v_attack_timer_timeout() -> void:
	var count = randi_range(0, 4)
	
	var activated: Array = [0, 1, 2, 3]
	activated.shuffle()
	activated.resize(randi_range(1, 4))

	await $Tentacles.attack_vertical(activated)
	
	$VAttackTimer.wait_time = randf_range(
		0.5,
		1.0
	) * max(count, 0.5)
	$VAttackTimer.start()
