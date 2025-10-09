@tool
extends Eel

@export var level_bound_left = -320
@export var level_bound_right = 320
@export var target: Node2D


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	_start_spawn_sequence.call_deferred()


func _on_screen_exited() -> void:
	if Engine.is_editor_hint():
		return

	if health.is_dead:
		return

	await get_tree().create_timer(1.0, false).timeout
	_start_spawn_sequence.call_deferred()


func _pick_target() -> bool:
	if target == null:
		if Globals.player == null:
			return false

		target = Globals.player

	return true


func _start_spawn_sequence() -> void:
	if not _pick_target():
		push_warning("Could not pick target!")
		return

	if _facing == Facing.Horizontal.LEFT:
		global_position.x = level_bound_left
	else:
		global_position.x = level_bound_right

	global_position.y = target.global_position.y
	_facing = Facing.opposite_h(_facing)
