extends Node2D
class_name EndlessLevel

@onready var current_level: Level = $Level
@onready var player: Player = $"../Player"

@export var transition_duration: float = 1.5

@export var level_height_in_tiles: int = 24
@export var tile_size: int = 16

var _is_transition_in_progress: bool = false:
	get:
		return _is_transition_in_progress
	set(value):
		_is_transition_in_progress = value
		if value:
			_freeze_player()
		else:
			_release_player()

var _level_height_total: float:
	get:
		return tile_size * level_height_in_tiles

@export var level_part_prefabs: Array[PackedScene] = []
@export var enemy_prefabs: Array[PackedScene] = []

func _ready() -> void:
	Globals.reset()
	Globals.player = $"../Player"
	Globals.level = self

	current_level = $Level
	current_level.Finished.connect(next_level)
	
	# _generate_level.call_deferred(current_level)

func _generate_level(level: Level) -> void:
	level.generate(level_part_prefabs, enemy_prefabs)

func next_level() -> void:
	_transition_to_next_level.call_deferred()

func _transition_to_next_level() -> void:
	if _is_transition_in_progress:
		return

	_is_transition_in_progress = true
	
	Globals.current_room_index += 1

	var level_prefab: PackedScene = load("res://levels/generation/level.tscn")
	var new_level: Level = level_prefab.instantiate()
	_generate_level(new_level)
	add_child(new_level)

	var old_level_goal_position = Vector2.UP * _level_height_total
	var new_level_goal_position = Vector2.ZERO
	var player_goal_position = player.position + Vector2.UP * _level_height_total
	# HACK: offset slightly to create illusion of falling
	player_goal_position += Vector2.DOWN * (15.0 * tile_size)

	current_level.position = Vector2.ZERO
	new_level.position = Vector2.DOWN * _level_height_total

	var transition = create_tween()
	transition.set_parallel(true)
	transition.set_trans(Tween.TRANS_CUBIC)
	transition.set_ease(Tween.EASE_OUT)

	transition.tween_property(current_level, "position", old_level_goal_position, transition_duration)
	transition.tween_property(new_level, "position", new_level_goal_position, transition_duration)
	transition.tween_property(Globals, "depth", Globals.depth + _level_height_total, transition_duration)
	transition.tween_property(player, "position", player_goal_position, transition_duration)
	
	$"../Overlay/ObjectiveOverlay".show_objective("KILL", "EVERY", "FISH")

	await transition.finished

	var old_level = current_level
	current_level = new_level
	current_level.Finished.connect(next_level)

	old_level.queue_free()
	_is_transition_in_progress = false

func _freeze_player() -> void:
	player.is_in_transition = true

func _release_player() -> void:
	player.is_in_transition = false
