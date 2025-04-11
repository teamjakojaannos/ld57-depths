extends Area2D

@onready var room = $".."

var _triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	_triggered = true

	if body is Player:
		room.finish()
		queue_free()
