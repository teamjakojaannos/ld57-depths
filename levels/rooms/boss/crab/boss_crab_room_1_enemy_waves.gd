extends EnemyWaves

@export var wave_delay_min: float = 3.0
@export var wave_delay_max: float = 7.0

func _execute() -> void:
	await wait_player_landed()
	await wait(0.5)

	for i in 6:
		await spawn($BunchOfSpikeFish)
		await wait(randf_range(wave_delay_min, wave_delay_max))

		if i % 2 == 0:
			await spawn($SingleEel)
			await wait(randf_range(wave_delay_min, wave_delay_max))
