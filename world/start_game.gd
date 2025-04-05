extends Node

func _start_game():
	print("Starting game...")
	get_tree().change_scene_to_file("res://levels/game.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_start_game()
