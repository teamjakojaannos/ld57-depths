extends PathFollow2D

@export var move_speed: float = 10.0

var can_collide: bool:
	set(value):
		hurtbox.enabled = value
		hitbox.enabled = value
var _is_frozen: bool = true
var _move_direction: Facing.Horizontal = Facing.Horizontal.LEFT

@onready var visual_root: Node2D = $Mask
@onready var spawn_anim: AnimationPlayer = $SpawnAnimation
@onready var health: Health = Nodes.find_by_class(self, Health)
@onready var hurtbox: Hurtbox = Nodes.find_by_class(self, Hurtbox)
@onready var hitbox: Hitbox = Nodes.find_by_class(self, Hitbox)


static func _find_random_pos_on_top_side_of_path(path: Path2D) -> float:
	var curve: Curve2D = path.curve
	var length = curve.get_baked_length()

	var sample_pos = randf() * length
	var sample = curve.sample_baked_with_rotation(sample_pos)
	var is_on_top_side = sample.get_rotation() == 0.0

	var retry_count = 100
	while (!is_on_top_side):
		sample_pos = randf() * length
		sample = curve.sample_baked_with_rotation(sample_pos)
		is_on_top_side = sample.get_rotation() == 0.0

		retry_count -= 1
		if (retry_count == 0):
			break

	return sample_pos


func _ready() -> void:
	# immediately hide to avoid briefly blinking at 0,0
	spawn_anim.play("RESET_HIDDEN")
	spawn_anim.advance(0)

	_is_frozen = true
	can_collide = false

	_do_spawn.call_deferred()


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return

	if _is_frozen:
		return

	var dir_sign = Facing.sign_h(_move_direction)
	var signed_speed = move_speed * dir_sign
	progress += signed_speed * delta


func _do_spawn() -> void:
	# HACK: is_inside_tree check avoids errors when running current scene
	if is_inside_tree() and get_parent() is Path2D:
		progress = _find_random_pos_on_top_side_of_path(get_parent())

	await _play_spawn_animation()

	can_collide = true
	_is_frozen = false
	_move_direction = Facing.Horizontal.values().pick_random()


func _on_health_die() -> void:
	can_collide = false
	await _play_death_animation()
	queue_free()


func _play_death_animation() -> void:
	# Crab should be untouchable during the spawn anim, but reset to a known
	# "valid state", just in case.
	spawn_anim.play("RESET")
	spawn_anim.advance(0)

	var tween = create_tween()
	tween.set_parallel(true)

	var target_pos = visual_root.global_position + Vector2.DOWN * 100.0
	tween.tween_property(visual_root, "global_position", target_pos, 1.5)
	tween.tween_property(visual_root, "modulate", Color.TRANSPARENT, 1.5)

	await tween.finished


func _play_spawn_animation() -> void:
	spawn_anim.play("spawn")
	await spawn_anim.animation_finished
