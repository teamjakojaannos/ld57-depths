extends PathFollow2D

@export var move_speed = 10.0

func _ready() -> void:
	pass
	#progress_ratio = randf()

func _physics_process(delta: float) -> void:
	progress += move_speed * delta
