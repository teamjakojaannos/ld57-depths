@tool
extends GPUParticles2D

func _ready() -> void:
	emitting = true
	if get_node_or_null("Medium") != null:
		get_node_or_null("Medium").emitting = true
	$Small.emitting = true

	Signals.try_connect(finished, _on_finished)


func _on_finished() -> void:
	if Engine.is_editor_hint() and not Nodes.is_safe_to_free_in_editor(self):
		return

	queue_free()
