extends Node
class_name EnemyWaves

signal enemy_spawned(enemy: Node)

func _ready() -> void:
	run.call_deferred()

func _execute() -> void:
	push_error("Enemy waves does not override _execute()!")
	await wait(1.0)

func run() -> void:
	# Wait until the level rig signals the scene initialization is done.
	if Globals.player is not Player:
		await LevelRig.initial_scene_ready

	await _execute()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func wait_all(funcs: Array) -> void:
	await Promise.async_all(funcs)

func wait_player_landed() -> void:
	await Globals.player.landed

func spawn(wave: EnemyWave) -> void:
	var spawned = await wave.spawn()
	for enemy in spawned:
		enemy_spawned.emit(enemy)

func spawn_simultaneously(waves: Array[EnemyWave]) -> void:
	if waves.size() == 0:
		return

	var tasks = []
	for wave in waves:
		var promise = Promise.new()
		tasks.push_back(_do_spawn.bind(promise, wave))
	await Promise.async_all(tasks)

func _do_spawn(promise: Promise, wave: EnemyWave) -> Promise:
	await spawn(wave)

	promise.resolve()
	return promise
