extends Parallax2D

func _process(_delta: float) -> void:
	var scroll = Globals.depth
	var idle_scroll = Globals.idle_depth

	screen_offset.y = scroll + idle_scroll
