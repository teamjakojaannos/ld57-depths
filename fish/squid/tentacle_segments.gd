@tool
extends Node2D

@export var wave_count: float = 14.0
@export var max_amplitude: float = 2
@export var time_scale: float = 14.0

@onready var time_offset = randi_range(0, 1000)

func _process(_delta: float) -> void:
	var segment_count = get_child_count()
	
	var idx = 0
	for child in get_children():
		child.position.x = idx * 32.0
		var time = Time.get_ticks_msec() / 1000.0
		time *= time_scale
		time += time_offset
		var time_offs = idx * (1.0 / segment_count) * wave_count
		
		child.position.y = sin(time + time_offs) * max_amplitude
		idx += 1
