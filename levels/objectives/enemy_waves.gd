class_name EnemyWaves
extends Node

signal enemy_spawned(enemy: Node)


func run() -> void:
	# Wait until the level rig signals the scene initialization is done.
	if Globals.player is not Player:
		await LevelRig.initial_scene_ready

	await _execute()


func spawn(wave: EnemyWave, wait_until_spawned: bool = false) -> void:
	var spawned = await wave.spawn(wait_until_spawned)
	for enemy in spawned:
		enemy_spawned.emit(enemy)


func spawn_simultaneously(
		waves: Array[EnemyWave],
		wait_until_spawned: bool = false,
) -> void:
	if waves.size() == 0:
		return

	var tasks = []
	for wave in waves:
		var promise = Promise.new()
		tasks.push_back(_async_spawn.bind(promise, wave, wait_until_spawned))
	await Promise.async_all(tasks)


func wait(seconds: float) -> void:
	if seconds <= 0.0:
		return

	await get_tree().create_timer(seconds, false).timeout


func wait_all(funcs: Array) -> void:
	await Promise.async_all(funcs)


func wait_player_landed() -> void:
	await Globals.player.landed


func _async_spawn(
		promise: Promise,
		wave: EnemyWave,
		wait_until_spawned: bool,
) -> Promise:
	await spawn(wave, wait_until_spawned)

	promise.resolve()
	return promise


func _execute() -> void:
	push_error("Enemy waves does not override _execute()!")
	await wait(1.0)
