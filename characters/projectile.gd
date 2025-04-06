@tool
class_name Projectile
extends Area2D

@export var point_at_velocity: bool = true
@export var destroy_on_damage: bool = true

@export var fall_speed: float = 0.0
@export var damage: float = 1.0:
	get:
		var hurtbox = get_node_or_null("Hurtbox")
		if hurtbox is Hurtbox:
			return hurtbox.damage
		return 1.0
	set(value):
		var hurtbox = get_node_or_null("Hurtbox")
		if hurtbox is Hurtbox:
			hurtbox.damage = value

@export var trail_particle_emitter: GPUParticles2D

var velocity: Vector2 = Vector2.RIGHT * 100.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not $Hurtbox.hurt_target.is_connected(_on_hurtbox_hurt_target):
		$Hurtbox.hurt_target.connect(_on_hurtbox_hurt_target)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	position += velocity * delta
	velocity.y -= fall_speed * delta

	if point_at_velocity:
		rotation = velocity.angle()


func _on_body_entered(_other: Node2D) -> void:
	if Engine.is_editor_hint():
		return

	# Hit something hard => destroy
	_destroy()


func _on_hurtbox_hurt_target(_other) -> void:
	if Engine.is_editor_hint():
		return

	if destroy_on_damage:
		_destroy()


func _destroy() -> void:
	if Engine.is_editor_hint():
		return

	if trail_particle_emitter is GPUParticles2D:
		trail_particle_emitter.reparent(Globals.current_level)
		trail_particle_emitter.emitting = false
		self.queue_free()
		await get_tree().create_timer(10.0).timeout
		trail_particle_emitter.queue_free()
	else:
		self.queue_free()
