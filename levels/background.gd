extends Parallax2D

func _process(_delta: float) -> void:
	var scroll = Globals.depth

	screen_offset.y = scroll
