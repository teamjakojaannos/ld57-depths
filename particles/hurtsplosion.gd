extends GPUParticles2D

func _ready() -> void:
	emitting = true
	if get_node_or_null("Medium") != null:
		get_node_or_null("Medium").emitting = true
	$Small.emitting = true
