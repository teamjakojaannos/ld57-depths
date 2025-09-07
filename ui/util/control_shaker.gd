@tool
extends Control
class_name ControlShaker

@export_range(0.0, 1.0) var shake_fade_speed = 0.25

@export_group("Debug")
@export_tool_button("Shake!", "Callable")
var shake_action = _debug_shake
@export var debug_shake_intensity: float = 5.0

func _debug_shake() -> void:
	shake(debug_shake_intensity)

var _shake_intensity: float = 0.0

func shake(intensity: float) -> void:
	_shake_intensity = intensity

func _process(_delta: float) -> void:
	if _shake_intensity < 0.01:
		position = Vector2.ZERO
		return

	position = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
	).normalized() * _shake_intensity

	_shake_intensity = _shake_intensity * (1.0 - shake_fade_speed)
