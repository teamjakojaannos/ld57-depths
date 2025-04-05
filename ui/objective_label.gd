@tool
extends Label

@export_range(-1.0, 1.0, 0.01)
var slide_offset: float = 0.0:
	get:
		return slide_offset
	set(value):
		slide_offset = value

		var bounds = get_rect()
		position.x = bounds.size.x * slide_offset
