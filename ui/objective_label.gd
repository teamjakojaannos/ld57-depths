@tool
extends Label

@export
var slide_up: bool = false

@export_range(-1.0, 1.0, 0.01)
var slide_offset: float = 0.0:
	get:
		return slide_offset
	set(value):
		slide_offset = value

		var bounds = get_rect()
		if slide_up:
			position.y = bounds.size.y * slide_offset
		else:
			position.x = bounds.size.x * slide_offset
