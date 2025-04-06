extends GPUParticles2D

func _ready() -> void:
	emitting = true
	$Medium.emitting = true
	$Small.emitting = true
