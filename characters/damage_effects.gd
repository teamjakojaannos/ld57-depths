@tool
extends Node
class_name DamageEffects


@export var emit_particles: bool = true
@export var nudge: bool = true
@export var flash: bool = true

@export_group("Particles")
@export var particle_emitter: PackedScene = preload("uid://dkgpgoo61sytr")


@export_group("Nudge")
## The node which position will be adjusted when nudged.
@export var nudge_pivot: Node2D

## The amount (in pixels) the will move at maximum.
@export var nudge_amount: float = 2.0

## Time until the node is back to its original position.
@export var nudge_duration: float = 0.3

@export_group("Flash")
## The node which color will be adjusted when flashing.
@export var flash_node: Node2D
## How many times the node should flash.
@export var flash_times: int = 1
## Total duration how long the node will spend flashing.
@export var flash_duration = 0.3
## Color the node will flash to.
@export var flash_color: Color = Color.RED

@export_group("Advanced")
@export var health: Health


@export_category("Debug")
@export_tool_button("Preview", "Callable")
var debug_preview_action = _preview

func _preview() -> void:
	# HACK: just use some Node2D as parent as things are not moving in-editor.
	_apply(get_parent(), Vector2.ZERO)


var _nudger: Tween
var _flasher: Tween

func _ready() -> void:
	health = Nodes.find_if_null(get_parent(), health, Health)

	if not Objects.is_null(health):
		Signals.try_connect(health.hurt_at, _on_health_hurt_at)

func _on_health_hurt_at(hurt_pos: Vector2):
	_apply(Globals.current_room, hurt_pos)

func _apply(room: Node2D, hurt_pos: Vector2) -> void:
	if emit_particles: _emit_particles(room, hurt_pos)
	if nudge: _nudge()
	if flash: _flash()

func _emit_particles(room: Node2D, hurt_pos: Vector2) -> void:
	if particle_emitter == null:
		return

	var emitter: Node2D = particle_emitter.instantiate()
	emitter.global_position = hurt_pos

	Nodes.mark_as_safe_to_free(emitter)
	room.add_child(emitter)

func _nudge() -> void:
	if nudge_pivot is not Node2D:
		return

	# If nudge is already in progress, immediately finish it.
	if _nudger != null:
		_nudger.custom_step(99999)
		_nudger = null

	_nudger = create_tween()
	_nudger.set_parallel(false)
	_nudger.set_trans(Tween.TRANS_QUAD)
	_nudger.tween_property(
		nudge_pivot,
		"position",
		Vector2(0.0, nudge_amount),
		nudge_duration * 0.2
	)
	_nudger.tween_property(
		nudge_pivot,
		"position",
		Vector2(0.0, 0.0),
		nudge_duration * 0.8
	)
	_nudger.play()

func _flash() -> void:
	if flash_times < 1:
		return

	# If flash is already in progress, immediately finish it.
	if _flasher != null:
		_flasher.custom_step(99999)
		_flasher = null

	var neutral_color = flash_node.modulate
	_flasher = create_tween()
	_flasher.set_parallel(false)
	_flasher.set_trans(Tween.TRANS_LINEAR)

	var d = flash_duration / flash_times
	_flasher.loop_finished.connect(func(_i): flash_node.modulate = flash_color)
	_flasher.tween_property(flash_node, "modulate", neutral_color, d)
	_flasher.set_loops(flash_times)
	flash_node.modulate = flash_color
	_flasher.play()
