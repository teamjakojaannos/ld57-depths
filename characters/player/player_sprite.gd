@tool
extends Node2D

@onready var player: Player = $".."

var animation_root: AnimationNodeStateMachinePlayback:
	get:
		return $AnimationTree["parameters/playback"]

enum Facing {
	LEFT,
	RIGHT,
}

@export var debug_facing: Facing = Facing.RIGHT
@export var debug_is_walking: bool = false
@export var debug_is_falling: bool = false
@export var debug_is_crouching: bool = false

@export_tool_button("Jump")
var debug_player_jump: Callable = _on_player_jumped

@export_tool_button("Die")
var debug_player_die: Callable = _on_player_die


var is_walking: bool:
	get:
		if Engine.is_editor_hint():
			return debug_is_walking

		return player.is_moving

var is_crouching: bool:
	get:
		if Engine.is_editor_hint():
			return debug_is_crouching

		return player.is_crouching

var is_falling: bool:
	get:
		if Engine.is_editor_hint():
			return debug_is_falling

		return !player.is_on_floor()

var facing: Facing:
	get:
		if Engine.is_editor_hint():
			return debug_facing

		if player.looking_at == Player.LookingAt.LEFT:
			return Facing.LEFT
		else:
			return Facing.RIGHT


func _on_player_jumped() -> void:
	animation_root.travel("action_jump")

func _on_player_hurt() -> void:
	var blinker = create_tween()
	blinker.set_trans(Tween.TRANS_EXPO)

	var blink_duration = 0.1
	blinker.tween_property(player, "modulate", Color.ORANGE_RED, blink_duration * 0.5)
	blinker.tween_property(player, "modulate", Color.WHITE, blink_duration * 0.5)
	blinker.set_loops(10)

func _on_player_die() -> void:
	animation_root.travel("action_die")
