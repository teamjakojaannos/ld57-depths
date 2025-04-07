extends PathFollow2D

@export var move_speed = 10.0
var move_direction: int = 1

func _ready() -> void:
	progress_ratio = randf()
	var moves_forward = randi_range(0, 1) == 0
	move_direction = 1 if moves_forward else -1

func _physics_process(delta: float) -> void:
	progress += move_speed * move_direction * delta
