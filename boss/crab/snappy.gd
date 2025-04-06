extends Node2D

@export var points: Array[Marker2D] = []

@export var attack_chance: float = 0.4
@export var attack_idle_min: float = 1.5
@export var attack_idle_max: float = 3.5

signal attack_finished

func retreat() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", Vector2.DOWN * 1000.0, 1.5)

func attack() -> void:
	var point = points.pick_random()

	global_position = point.global_position

	if randf() < attack_chance:
		$AnimationPlayer.play("enter")
		await $AnimationPlayer.animation_finished
		
		$AnimationPlayer.play("idle")
		var wait_time = randf_range(attack_idle_min, attack_idle_max)
		await get_tree().create_timer(wait_time).timeout
		
		$AnimationPlayer.play("attack")
		await $AnimationPlayer.animation_finished
	else:
		$AnimationPlayer.play("peek")
		await $AnimationPlayer.animation_finished
	
	attack_finished.emit()
