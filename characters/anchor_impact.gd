extends Node

# TODO: replace with proper sounds!
const mob_impact: AudioStream = preload("uid://dvd74jspqa7l5")
const wall_impact: AudioStream = preload("uid://dwg51c0vur3xw")

func _on_hurtbox_hurt_target(_other: Hitbox) -> void:
	var stream = AudioStreamPlayer.new()
	stream.stream = mob_impact
	stream.volume_db = -3.0
	stream.bus = "Player Guns SFX"

	Globals.current_level.add_child(stream)
	stream.play()


func _on_anchor_body_entered(_body: Node2D) -> void:
	var stream = AudioStreamPlayer.new()
	stream.stream = wall_impact
	stream.volume_db = -2.5
	stream.bus = "Player Guns SFX"

	Globals.current_level.add_child(stream)
	stream.play()
