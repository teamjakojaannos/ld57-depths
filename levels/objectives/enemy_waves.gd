extends Node
class_name EnemyWaves

signal execute

func _ready() -> void:
	start.call_deferred()
	
	# Attempt to connect to the default execute fn
	var exec_callable = Callable.create(self, "_execute")
	if exec_callable.is_valid():
		execute.connect(exec_callable)

func start() -> void:
	# Wait until the level rig signals the scene initialization is done.
	if Globals.player is not Player:
		await LevelRig.initial_scene_ready

	execute.emit.call_deferred()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func wait_all(funcs: Array) -> void:
	await Promise.async_all(funcs)

func wait_player_landed() -> void:
	await Globals.player.landed

func spawn(wave: EnemyWave) -> void:
	await wave.spawn()

func spawn_simultaneously(waves: Array[EnemyWave]) -> void:
	var tasks = []
	for wave in waves:
		var promise = Promise.new()
		tasks.push_back(_do_spawn.bind(promise, wave))
	await Promise.async_all(tasks)

func _do_spawn(promise: Promise, wave: EnemyWave) -> Promise:
	await spawn(wave)

	promise.resolve()
	return promise
