@tool
extends Node
class_name Health


signal hurt
signal healed
signal die

## Fired when hurt too soon after taking damage and damage instance is ignored.
signal hurt_too_soon

## Fired when is_invulnerable is true and taking damage.
signal hurt_invulnerable

## Fired when taking damage. Returns the position of the node dealing the
## damage.
signal hurt_at(position: Vector2)

@export var max_health: float = 10

@export var invulnerable_time_after_damage: float = 0.1
var _was_just_hurt = false

@export var is_invulnerable: bool = false

var is_dead: bool:
	get:
		return _health <= 0

var current_health: float:
	get:
		return _health

var _is_killed: bool = false
var _health: float = 10

static func find(node: Node) -> Health:
	if node == null:
		return null

	if node is Health:
		return node

	var by_name = node.get_node_or_null("Health")
	if by_name is Health:
		return by_name

	for child in node.get_children():
		if child is Health:
			return child

	return null

func heal(amount: float, _from: Node) -> void:
	var old_health = _health
	_health = clamp(_health + amount, 0, max_health)
	_check_signals(old_health, Vector2.INF)

func take_damage(amount: float, _from: Node) -> void:
	_try_take_damage(amount, _from, Vector2.INF)

func take_damage_at(amount: float, _from: Node, point: Vector2) -> void:
	_try_take_damage(amount, _from, point)

func _try_take_damage(amount: float, _from: Node, point: Vector2) -> void:
	if _was_just_hurt:
		hurt_too_soon.emit()
		return

	if is_invulnerable:
		hurt_invulnerable.emit()
		return

	var old_health = _health
	_health = clamp(_health - amount, 0, max_health)
	_check_signals(old_health, point)

	if invulnerable_time_after_damage > 0:
		_was_just_hurt = true
		await get_tree().create_timer(invulnerable_time_after_damage, false).timeout
		_was_just_hurt = false

func _ready() -> void:
	_health = max_health


func _check_signals(old_health: float, point: Vector2) -> void:
	if Engine.is_editor_hint() or _is_killed:
		return

	var change = _health - old_health
	if change > 0:
		healed.emit()
	elif change < 0:
		hurt.emit()
		if point.is_finite():
			hurt_at.emit(point)

	if is_dead:
		_is_killed = true
		die.emit()
