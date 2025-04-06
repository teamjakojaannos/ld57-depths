extends Label

func _process(_delta: float) -> void:
	text = "Level: %s" % Globals.current_room_index
