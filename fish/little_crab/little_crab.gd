extends PathFollow2D

@export var move_speed = 10.0
var move_direction: int = 1

func _ready() -> void:
	progress_ratio = randf()
	var moves_forward = randi_range(0, 1) == 0
	move_direction = 1 if moves_forward else -1

func _physics_process(delta: float) -> void:
	if $Health.is_dead:
		return

	progress += move_speed * move_direction * delta


func _on_health_die() -> void:
	Globals.current_level.record_kill()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($CrabRoot, "global_position", $CrabRoot.global_position + Vector2.DOWN * 100.0, 1.5)
	tween.tween_property($CrabRoot, "modulate", Color.TRANSPARENT, 1.5)
	await tween.finished
	queue_free()

func _on_health_hurt() -> void:
	var blinker = create_tween()
	blinker.set_trans(Tween.TRANS_EXPO)

	var blink_duration = 0.1
	blinker.tween_property($CrabRoot, "modulate", Color.ORANGE_RED, blink_duration * 0.5)
	blinker.tween_property($CrabRoot, "modulate", Color.WHITE, blink_duration * 0.5)
