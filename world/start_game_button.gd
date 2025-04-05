extends Button

func _start_button_pressed():
	print("Starting game...")
	get_tree().change_scene_to_file("res://world/level.tscn")
