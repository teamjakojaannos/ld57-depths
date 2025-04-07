extends AudioStreamPlayer

func play_hurt_sound() -> void:
	pitch_scale = randf_range(0.80, 1.20)
	play()
