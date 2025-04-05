extends Node
class_name Lifetime

@export var duration = 3.0

func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(_on_timeout)

func _on_timeout() -> void:
	get_parent().queue_free()
