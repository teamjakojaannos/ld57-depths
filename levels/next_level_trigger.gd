extends Area2D

@onready var level = $".."

var _triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	_triggered = true

	if body is Player:
		level.finish()
		queue_free()
