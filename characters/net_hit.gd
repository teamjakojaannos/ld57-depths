extends Node

const impact: AudioStream = preload("uid://ueghqmkr3kfj")

func _on_hurtbox_hurt_target(_other: Hitbox) -> void:
	var stream = AudioStreamPlayer.new()
	stream.stream = impact
	stream.volume_db = 0.0
	stream.bus = "Player Guns SFX"

	Globals.current_level.add_child(stream)
	stream.play()
