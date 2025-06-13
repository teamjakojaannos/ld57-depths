## Adaptor to spawn legacy spawnlists with the enemy wave thingamajig.
class_name LegacySpawnlistEnemyWaves
extends EnemyWaves

@export var spawnlist: Spawnlist
@export var min_waves: int = 1
@export var max_waves: int = 3

@export var wave_delay_min: float = 1.0
@export var wave_delay_max: float = 5.0

func _execute() -> void:
	await wait_player_landed()
	await wait(0.5)

	for i in randi_range(min_waves, max_waves):
		await _spawn_wave()
		await wait(randf_range(wave_delay_min, wave_delay_max))

func _spawn_wave() -> void:
	var enemies: Array[EnemyWave] = []

	var spent_cost = 0
	while spent_cost < spawnlist.total_cost:
		var s: Spawnable = spawnlist.enemies.pick_random()
		spent_cost += s.spawn_cost

		# HACK: spawn each enemy as a separate wave
		var enemy = EnemyWave.new()
		enemy.enemy = s.prefab
		enemy.count_min = 1
		enemy.count_max = 1
		enemy.spawn_group = EnemyWave.SpawnGroup.OFF_SCREEN_SIDE
		if s.spawnpoint_group == Spawnable.SpawnGroup.PATH_FOLLOWER:
			enemy.spawn_group = EnemyWave.SpawnGroup.ON_PLATFORM_PATH
		add_child(enemy)

		enemies.push_back(enemy)

	await spawn_simultaneously(enemies)
	
