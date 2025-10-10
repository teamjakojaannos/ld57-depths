class_name AnimatedSpriteImporterInspectorPlugin
extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	if object is not AnimationPlayer:
		return false

	var anim_player := object as AnimationPlayer
	return anim_player.get_parent() is AnimatedSprite2D


func _on_import_button_pressed(anim_player: AnimationPlayer) -> void:
	var sprite: AnimatedSprite2D = anim_player.get_parent()
	anim_player.root_node = ".."

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
		var animation := Animation.new()
		library.add_animation(animation_name, animation)

		var animation_track = animation.add_track(Animation.TYPE_VALUE)
		animation.value_track_set_update_mode(animation_track, Animation.UPDATE_DISCRETE)
		animation.track_set_interpolation_type(animation_track, Animation.INTERPOLATION_NEAREST)
		animation.track_set_path(animation_track, ".:animation")

		var frame_track = animation.add_track(Animation.TYPE_VALUE)
		animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
		animation.track_set_interpolation_type(frame_track, Animation.INTERPOLATION_NEAREST)
		animation.track_set_path(frame_track, ".:frame")

		animation.track_insert_key(animation_track, 0.0, animation_name)

		var frame_count = sprite_frames.get_frame_count(animation_name)
		var fps = sprite_frames.get_animation_speed(animation_name)
		var t := 0.0
		for frame in frame_count:
			animation.track_insert_key(frame_track, t, frame)

			var frame_duration = sprite_frames.get_frame_duration(animation_name, frame)
			t += frame_duration / fps

		animation.length = t
		var is_looping = sprite_frames.get_animation_loop(animation_name)
		if is_looping:
			animation.loop_mode = Animation.LOOP_LINEAR
		else:
			animation.loop_mode = Animation.LOOP_NONE

		if not sprite.autoplay.is_empty():
			anim_player.autoplay = "sprite/%s" % sprite.autoplay


func _parse_category(object: Object, category: String) -> void:
	if category != "AnimationPlayer":
		return

	var button := Button.new()
	button.text = "Import from parent sprite"
	var action = _on_import_button_pressed.bind(object)
	button.pressed.connect(action)

	add_custom_control(button)
