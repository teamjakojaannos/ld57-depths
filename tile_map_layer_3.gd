extends TileMapLayer

@onready var start_y = position.y

@export var wave_size = 5
@export var time_scale = 1


func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	position.y = start_y + sin(time*time_scale) * wave_size 
