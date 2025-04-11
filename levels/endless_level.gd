extends Node2D
class_name EndlessLevel

@onready var current_level: Level = $Level
@onready var level_generator: LevelGenerator = $LevelGenerator

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

func _ready() -> void:
	Globals.reset()
	Globals.level = self
	Globals.current_level = $Level

	current_level = $Level
	current_level.Finished.connect(next_level)

func next_level() -> void:
	_transition_to_next_level.call_deferred()

func _transition_to_next_level() -> void:
	if _is_transition_in_progress:
		return

	_is_transition_in_progress = true

	Globals.current_room_index += 1
	
	var new_level: Level = level_generator.generate(self)

	_play_transition_animation.call_deferred(new_level)
	
	var music_to_play = _get_music_to_play()
	var current_song = Globals.music.current_song
	
	if music_to_play != current_song:
		Globals.music.play_song(music_to_play)

func _get_music_to_play() -> Jukebox.Song:
	var room_index = Globals.current_room_index
	var boss_rooms = [24, 25, 26, 50]
	var shop_rooms = [8, 9, 15, 16, 22, 23, 27, 28, 34, 35, 41, 42, 48, 49]
	if boss_rooms.has(room_index):
		return Jukebox.Song.Boss_1
	
	if shop_rooms.has(room_index):
		return Jukebox.Song.Shop
	
	var medium_depth = 17
	return Jukebox.Song.Music_1 if room_index < medium_depth else Jukebox.Song.Music_2


func _play_transition_animation(new_level: Level) -> void:
	var old_level_goal_position = Vector2.UP * _level_height_total
	var new_level_goal_position = Vector2.ZERO
	var player_goal_position = Globals.player.position + Vector2.UP * _level_height_total
	# HACK: offset slightly to create illusion of falling
	player_goal_position += Vector2.DOWN * (15.0 * tile_size)

	current_level.position = Vector2.ZERO
	new_level.position = Vector2.DOWN * _level_height_total

	# await get_tree().create_timer(1.0).timeout

	var transition = create_tween()
	transition.set_parallel(true)
	transition.set_trans(Tween.TRANS_CUBIC)
	transition.set_ease(Tween.EASE_OUT)

	transition.tween_property(current_level, "position", old_level_goal_position, transition_duration)
	transition.tween_property(new_level, "position", new_level_goal_position, transition_duration)
	transition.tween_property(Globals, "depth", Globals.depth + _level_height_total, transition_duration)
	transition.tween_property(Globals.player, "position", player_goal_position, transition_duration)
	
	var entry_text = ["KILL", "EVERY", "FISH"]
	if new_level.entry_text != null && !new_level.entry_text.is_empty():
		entry_text = new_level.entry_text
	UI.objective_overlay.show_objective(entry_text[0], entry_text[1], entry_text[2], 1.0)

	var d = Globals.current_room_index / 100.0
	$Bubbles.pitch_scale = lerp(1.05, 0.35, d)
	$Bubbles.play()

	await transition.finished

	var old_level = current_level
	current_level = new_level
	Globals.current_level = new_level
	current_level.Finished.connect(next_level)

	old_level.queue_free()
	_is_transition_in_progress = false

func _freeze_player() -> void:
	Globals.player.is_in_transition = true

func _release_player() -> void:
	Globals.player.is_in_transition = false
