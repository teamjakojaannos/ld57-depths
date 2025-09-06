extends Node2D
class_name EndlessLevel

@onready var current_room: Room
@onready var level_generator: LevelGenerator = $LevelGenerator

@export var transition_duration: float = 1.5
@export var room_height_in_tiles: int = 36
@export var tile_size: int = 16

var _is_player_ready: bool = false

var _is_transition_in_progress: bool = false:
	get:
		return _is_transition_in_progress || !_is_player_ready
	set(value):
		_is_transition_in_progress = value
		if value:
			_freeze_player()
		else:
			_release_player()

var _room_height_total: float:
	get:
		return tile_size * room_height_in_tiles

func _ready() -> void:
	Globals.reset()
	Globals.level = self

	_is_player_ready = false

func _process(delta: float) -> void:
	if _is_player_ready:
		set_process(false)
		return

	_freeze_player()
	Globals.idle_depth += 64.0 * delta

func _input(event: InputEvent) -> void:
	if _is_player_ready:
		set_process_input(false)
		return

	if event.is_action_pressed("jump"):
		_is_player_ready = true

		var transition = create_tween()
		transition.set_parallel(true)
		transition.set_trans(Tween.TRANS_CUBIC)
		transition.set_ease(Tween.EASE_IN_OUT)

		transition.tween_property($Overlay/Label, "slide_offset", -0.65, 1.0)

		_release_player()
		await get_tree().create_timer(0.75).timeout

		_transition_to_next_room.call_deferred()

func _transition_to_next_room() -> void:
	if _is_transition_in_progress:
		return

	_is_transition_in_progress = true

	Globals.current_room_index += 1

	var room_override_scene: PackedScene = \
		null if current_room == null else current_room.next_room
	var new_room: Room
	if room_override_scene is PackedScene:
		var room_override = room_override_scene.instantiate()
		if room_override is not Room:
			var scene_name = room_override_scene.resource_path
			push_error("Next room override \"%s\" is not a Room!" % scene_name)

		new_room = room_override
	else:
		new_room = level_generator.generate()

	add_child(new_room)

	_play_transition_animation.call_deferred(new_room)

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


func _play_transition_animation(new_room: Room) -> void:
	var old_room_goal_position = Vector2.UP * _room_height_total
	var new_room_goal_position = Vector2.ZERO
	var player_goal_position = Globals.player.position + Vector2.UP * _room_height_total
	# HACK: offset slightly to create illusion of falling
	player_goal_position += Vector2.DOWN * (15.0 * tile_size)

	var transition = create_tween()
	transition.set_parallel(true)
	transition.set_trans(Tween.TRANS_CUBIC)
	transition.set_ease(Tween.EASE_OUT)

	if current_room != null:
		current_room.position = Vector2.ZERO
		transition.tween_property(current_room, "position", old_room_goal_position, transition_duration)

	new_room.position = Vector2.DOWN * _room_height_total
	transition.tween_property(new_room, "position", new_room_goal_position, transition_duration)

	transition.tween_property(Globals, "depth", Globals.depth + _room_height_total, transition_duration)
	transition.tween_property(Globals.player, "position", player_goal_position, transition_duration)

	var entry_text = ["KILL", "EVERY", "FISH"]
	if new_room.entry_text != null && !new_room.entry_text.is_empty():
		entry_text = new_room.entry_text
	UI.objective_overlay.show_objective(entry_text[0], entry_text[1], entry_text[2], 1.0)

	var d = Globals.current_room_index / 100.0
	$Bubbles.pitch_scale = lerp(1.05, 0.35, d)
	$Bubbles.play()

	await transition.finished

	var old_room = current_room
	current_room = new_room
	Globals.current_room = new_room
	current_room.finished.connect(
		func():
			_transition_to_next_room.call_deferred()
	)

	if old_room != null:
		old_room.queue_free()

	LevelRig.regenerate_navmesh()

	_is_transition_in_progress = false

func _freeze_player() -> void:
	Globals.player.is_in_transition = true

func _release_player() -> void:
	Globals.player.is_in_transition = false
