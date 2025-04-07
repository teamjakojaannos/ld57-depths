extends AudioStreamPlayer

func play_hurt_sound() -> void:
	pitch_scale = randf_range(0.80, 1.20)
	play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch"):
		play_hurt_sound()
	
