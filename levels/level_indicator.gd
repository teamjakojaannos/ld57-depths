extends Label

func _process(_delta: float) -> void:
	var tutorial_room_count = 2
	var current = Globals.current_room_index
	if current <= tutorial_room_count:
		text = "Tutorial level %s" % (current + 1)
	else:
		var idx = current - tutorial_room_count
		text = "Level: %s" % idx
		
