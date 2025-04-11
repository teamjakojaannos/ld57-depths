extends Node

func _start_game():
	print("Starting game...")
	LevelRig.start_game()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_start_game()


func _on_intro_finished() -> void:
	_start_game()
