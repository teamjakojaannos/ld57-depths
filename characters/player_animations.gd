extends AnimationPlayer

@onready var player: Player = $".."

var _is_jumping = false

func _process(_delta: float) -> void:
	var anim_direction = "left"
	match player.looking_at:
		Player.LookingAt.LEFT:
			anim_direction = "left"
		Player.LookingAt.RIGHT:
			anim_direction = "right"

	if !player.is_dead and player.is_on_floor():
		_is_jumping = false

		var anim = "idle"
		if player.is_moving:
			anim = "walk"

		play("%s_%s" % [anim, anim_direction])
	
	if !player.is_dead and !player.is_on_floor():
		var anim = "fall"
		if _is_jumping:
			anim = "jump"

		play("%s_%s" % [anim, anim_direction])


func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"jump_left":
			play("fall_left")
			_is_jumping = false
		"jump_right":
			play("fall_right")
			_is_jumping = false
		_:
			pass


func _on_player_jumped() -> void:
	_is_jumping = true


func _on_player_died() -> void:
	play("die")


func _on_player_hurt() -> void:
	var blinker = create_tween()
	blinker.set_trans(Tween.TRANS_EXPO)

	var blink_duration = 0.1
	blinker.tween_property(player, "modulate", Color.ORANGE_RED, blink_duration * 0.5)
	blinker.tween_property(player, "modulate", Color.WHITE, blink_duration * 0.5)
	blinker.set_loops(10)
