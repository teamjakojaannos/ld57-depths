extends TextureRect

func _ready() -> void:
	Globals.stage_changed.connect(_refresh)

func _refresh() -> void:
	var ri = Globals.current_room_index
	
	var max_depth = 50.0
	var ratio = max(1.0, ri * 1.0) / max_depth
	var max_darkness = 1.0
	
	var x = lerp(1.0, 1.0 - max_darkness, ratio)
	modulate = Color(x, x, x, 1.0)
