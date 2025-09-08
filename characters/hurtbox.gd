## A region of 2D space that deals damage when it hits a Hitbox.
@tool
extends Area2D
class_name Hurtbox

signal hurt_target(target: Hitbox)

## Amount of damage applied.
@export var damage: float = 0.0

## How the damage should be applied.
@export var mode: Mode = Mode.ONCE:
	get:
		return mode
	set(value):
		mode = value
		_check_damage_timer()
		notify_property_list_changed()


## How often, in seconds, damage can is applied to targets.
@export var damage_interval: float = 0.1

## Can this area deal damage to multiple targets during a single tick.
@export var allow_hurt_multiple_targets: bool = true:
	get:
		return allow_hurt_multiple_targets
	set(value):
		allow_hurt_multiple_targets = value
		notify_property_list_changed()

## How many targets can be hurt during a single tick.
@export var max_targets_hurt: int = 10

var _is_timer_needed: bool:
	get:
		return mode == Mode.CONTINUOUS

var _damage_timer: Timer
var _tracked_targets: Array[Hitbox] = []

enum Mode {
	## Damage is applied only once when the target enters the hurtbox.
	ONCE,

	## Damage is continuously applied until the target leaves the hurtbox.
	CONTINUOUS
}

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"max_targets_hurt":
			Exports.visible_if(property, allow_hurt_multiple_targets, PROPERTY_USAGE_EDITOR)
		"damage_interval":
			Exports.visible_if(property, mode == Mode.CONTINUOUS, PROPERTY_USAGE_EDITOR)
		_: pass

func _ready() -> void:
	Signals.try_connect(area_entered, _on_area_entered)
	Signals.try_connect(area_exited, _on_area_exited)

	if Engine.is_editor_hint():
		return

	_check_damage_timer()


func _check_damage_timer() -> void:
	if _is_timer_needed:
		if _damage_timer == null:
			_damage_timer = Timer.new()
			_damage_timer.name = "DamageTick"
			_damage_timer.timeout.connect(_damage_tick)
			_damage_timer.wait_time = damage_interval
			add_child(_damage_timer, false, Node.INTERNAL_MODE_FRONT)

		if not _tracked_targets.is_empty() and _damage_timer.is_stopped():
			_damage_timer.start()
	elif not _is_timer_needed and _damage_timer != null:
		_damage_timer.queue_free()
		_damage_timer = null


func _damage_tick() -> void:
	var targets_hit = 0
	for target in _tracked_targets:
		if targets_hit >= max_targets_hurt:
			break

		_hurt_target(target)
		targets_hit += 1

	if _tracked_targets.is_empty():
		_damage_timer.stop()
		_check_damage_timer()


func _on_area_entered(other: Area2D) -> void:
	# Don't hit anything that cannot receive damage
	if other is not Hitbox or other.health.is_dead:
		return

	if mode == Mode.ONCE:
		_hurt_target(other)
	else:
		_track_target(other)
		_check_damage_timer()


func _on_area_exited(other: Area2D) -> void:
	if other is not Hitbox:
		return

	_tracked_targets.erase(other)


func _hurt_target(target: Hitbox) -> void:
	var final_damage = damage * target.multiplier
	target.health.take_damage_at(final_damage, self, global_position)

	hurt_target.emit(target)


func _track_target(target: Hitbox):
	if not _tracked_targets.has(target):
		_tracked_targets.push_back(target)
