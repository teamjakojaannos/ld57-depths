@tool
extends Eel

@export var level_bound_left = -200
@export var level_bound_right = 200


func _physics_process(delta: float) -> void:
	var is_moving_left = _facing == Facing.Horizontal.LEFT
	var is_moving_right = _facing == Facing.Horizontal.RIGHT

	var min_bound = min(level_bound_left, level_bound_right)
	var max_bound = max(level_bound_left, level_bound_right)

	var is_oob = false
	is_oob = is_oob || is_moving_left and position.x <= min_bound
	is_oob = is_oob || is_moving_right and position.x >= max_bound

	if is_oob:
		_facing = Facing.opposite_h(_facing)

	super._physics_process(delta)
