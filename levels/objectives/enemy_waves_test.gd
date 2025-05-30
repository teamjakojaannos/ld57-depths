extends EnemyWaves

func _execute() -> void:
	await wait_player_landed()
	await wait(1.0)

	await spawn_simultaneously([
		$SpikefishWaveSmall,
		$CrabWave,
	])
	await wait(5.0)

	for i in 2:
		await spawn($SpikefishWaveLarge)
		await wait(5.0)

	for i in 3:
		await wait(2.0)
		await spawn($Lionfish)
