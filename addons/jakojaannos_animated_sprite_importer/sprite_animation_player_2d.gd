@tool
class_name SpriteAnimationPlayer2D
extends AnimatedSprite2D

@export var animations: AnimationPlayer

@export_tool_button("Write to AnimationPlayer", "AnimationPlayer")
var write_to_anim_player = _do_sync
var _frame_offsets: Dictionary[StringName, PackedVector2Array] = { }
var _frame_offset: Vector2:
	get:
		if not _frame_offsets.has(animation):
			return Vector2.ZERO

		var offsets = _frame_offsets[animation]
		if not offsets:
			return Vector2.ZERO

		return offsets[frame]
	set(value):
		if not sprite_frames:
			return

		if not _frame_offsets.has(animation):
			var frame_count := sprite_frames.get_frame_count(animation)
			var new_array: PackedVector2Array = []
			new_array.resize(frame_count)
			new_array.fill(Vector2.ZERO)

			_frame_offsets[animation] = new_array

		var offsets = _frame_offsets[animation]
		var old_offset: Vector2 = offsets[frame]
		var new_offset := position - value
		#var delta = new_offset - old_offset

		offsets[frame] = new_offset
		offset = new_offset
		position = -new_offset


static func _add_discrete_animation_track(a: Animation, path: NodePath) -> int:
	var track = a.add_track(Animation.TYPE_VALUE)
	a.track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)
	a.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
	a.track_set_path(track, path)

	return track


static func _write_sprite_frames_to_animation(
		animation: Animation,
		animation_name: String,
		fps: float,
		loop_mode: Animation.LoopMode,
		frame_durations: Array[float],
) -> void:
	var animation_track = _add_discrete_animation_track(animation, ".:animation")
	animation.track_insert_key(animation_track, 0.0, animation_name)

	var frame_track = _add_discrete_animation_track(animation, ".:frame")
	var t := 0.0
	for frame in frame_durations.size():
		animation.track_insert_key(frame_track, t, frame)

		var frame_duration = frame_durations[frame] / fps
		t += frame_duration

	animation.length = t
	animation.loop_mode = loop_mode


static func _sync_sprite_to_animation(
		sprite: AnimatedSprite2D,
		anim_player: AnimationPlayer,
) -> void:
	anim_player.root_node = anim_player.get_path_to(sprite)

	var sprite_frames: SpriteFrames = sprite.sprite_frames
	if sprite_frames is not SpriteFrames:
		printerr("Import failed: %s is missing SpriteFrames!" % sprite)
		return

	var library: AnimationLibrary
	if anim_player.has_animation_library("sprite"):
		library = anim_player.get_animation_library("sprite")
		for animation in library.get_animation_list():
			library.remove_animation(animation)
	else:
		library = AnimationLibrary.new()
		anim_player.add_animation_library("sprite", library)

	var sprite_animations = sprite_frames.get_animation_names()

	for animation_name in sprite_animations:
		var fps := sprite_frames.get_animation_speed(animation_name)
		var frames := _get_frame_durations(sprite_frames, animation_name)
		var loop_mode := _select_loop_mode(sprite_frames, animation_name)

		var animation := Animation.new()
		library.add_animation(animation_name, animation)
		_write_sprite_frames_to_animation(
			animation,
			animation_name,
			fps,
			loop_mode,
			frames,
		)

	if not sprite.autoplay.is_empty():
		anim_player.autoplay = "sprite/%s" % sprite.autoplay


static func _get_frame_durations(
		sprite_frames: SpriteFrames,
		animation_name: StringName,
) -> Array[float]:
	var frame_count = sprite_frames.get_frame_count(animation_name)
	var frames: Array[float] = []
	for frame in frame_count:
		var d = sprite_frames.get_frame_duration(animation_name, frame)
		frames.push_back(d)

	return frames


static func _select_loop_mode(
		sprite_frames: SpriteFrames,
		animation_name: StringName,
) -> Animation.LoopMode:
	var is_looping = sprite_frames.get_animation_loop(animation_name)
	if is_looping:
		return Animation.LoopMode.LOOP_LINEAR
	else:
		return Animation.LoopMode.LOOP_NONE


func _enter_tree() -> void:
	_assign_owner()


func _ready() -> void:
	if not animations:
		_create_default_animation_player()

	if Engine.is_editor_hint():
		if not sprite_frames_changed.is_connected(_on_sprite_frames_changed):
			sprite_frames_changed.connect(_on_sprite_frames_changed)

		_on_sprite_frames_changed.call_deferred()


func _create_2d_gizmos(gizmos: EditorGizmos) -> void:
	gizmos.translate_2d("_frame_offset", _on_frame_offset_moved)


func _on_frame_offset_moved(new_pos: Vector2) -> void:
	_frame_offset = new_pos


func _assign_owner() -> void:
	if animations.owner:
		return

	if Engine.is_editor_hint():
		animations.owner = EditorInterface.get_edited_scene_root()
	else:
		animations.owner = self


func _create_default_animation_player() -> void:
	animations = AnimationPlayer.new()
	animations.name = "Animations"
	add_child(animations, true)


func _do_sync() -> void:
	_sync_sprite_to_animation.call_deferred(self, animations)


func _on_sprite_frames_changed() -> void:
	_do_sync()
	Signals.try_connect(sprite_frames.changed, _do_sync)
