class_name Projectile
extends Area2D

@export var point_at_velocity: bool = true
@export var destroy_on_damage: bool = true

@export var fall_speed: float = 0.0
@export var damage: float = 1

@export var trail_particle_emitter: GPUParticles2D

var velocity: Vector2 = Vector2.RIGHT * 100.0

func _ready() -> void:
	if not is_connected("body_entered", _on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if not is_connected("area_entered", _on_area_entered):
		area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += velocity * delta
	velocity.y -= fall_speed * delta

	if point_at_velocity:
		rotation = velocity.angle()


func _on_area_entered(other: Area2D) -> void:
	# Hit something with health => damage
	if other is Hitbox and not other.health.is_dead:
		# FIXME: there should be a reference to the shooter/real source
		#        here in the projectile to figure out who damaged whom
		# HACK: offset the damage position to push particle emitters into the
		#       damaged entity
		var offset = velocity * 0.5 * (1.0 / 60.0)
		other.health.take_damage_at(damage, self, global_position + offset)
		
		if destroy_on_damage:
			_destroy()

func _on_body_entered(other: Node2D) -> void:
	# Hit something hard => destroy
	_destroy()
	
	
func _destroy() -> void:
	if trail_particle_emitter is GPUParticles2D:
		trail_particle_emitter.reparent(Globals.current_level)
		trail_particle_emitter.emitting = false
		self.queue_free()
		await get_tree().create_timer(10.0).timeout
		trail_particle_emitter.queue_free()
	else:
		self.queue_free()
		
