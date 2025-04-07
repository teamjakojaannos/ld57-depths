@tool
extends Node
class_name Health

# FIXME: why are these PascalCase??
signal Die
signal Heal
signal Hurt

signal hurt_invincible
signal hurt_at(position: Vector2)

@export var max_health: float = 10

@export var invincible_time: float = 0.1
var _is_invincible = false

var is_dead: bool:
	get:
		return _health <= 0

var current_health: float:
	get:
		return _health

var _is_killed: bool = false
var _health: float = 10

func heal(amount: float, _from: Node) -> void:
	var old_health = _health
	_health = clamp(_health + amount, 0, max_health)
	_check_signals(old_health, Vector2.INF)

func take_damage(amount: float, _from: Node) -> void:
	_try_take_damage(amount, _from, Vector2.INF)

func take_damage_at(amount: float, _from: Node, point: Vector2) -> void:
	_try_take_damage(amount, _from, point)

func _try_take_damage(amount: float, _from: Node, point: Vector2) -> void:
	if _is_invincible:
		hurt_invincible.emit()
		return
	
	var old_health = _health
	_health = clamp(_health - amount, 0, max_health)
	_check_signals(old_health, point)
	
	if invincible_time > 0:
		_is_invincible = true
		await get_tree().create_timer(invincible_time).timeout
		_is_invincible = false

func _ready() -> void:
	_health = max_health


func _check_signals(old_health: float, point: Vector2) -> void:
	if Engine.is_editor_hint() or _is_killed:
		return

	var change = _health - old_health
	if change > 0:
		Heal.emit()
	elif change < 0:
		Hurt.emit()
		if point.is_finite():
			hurt_at.emit(point)
		
	if is_dead:
		_is_killed = true
		Die.emit()
