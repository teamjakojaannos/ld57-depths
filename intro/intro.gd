extends Node2D

signal finished


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Frank_falls":
		finished.emit()
