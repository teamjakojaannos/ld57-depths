extends Area2D

@export var damage = 2
@export var charge_speed = 200.0
@export var after_charge_speed = 100.0
var speed = 0.0

var braking_tween: Tween
var velocity = Vector2()

enum State {
	Idle,
	PreparingCharge,
	Charge,
	AfterCharge,
}

var current_state = State.Idle
var target = Vector2()
var velocity_weight = 0.0

func _ready() -> void:
	start_idling()

func _physics_process(delta: float) -> void:
	var close_enough = 100.0
	if $Health.is_dead:
		position += velocity
		return
	
	if current_state == State.Charge:
		velocity = (target - position).normalized() * delta * speed

		if position.distance_squared_to(target) <= close_enough:
			run_away_after_charge()
			return
	
	if current_state == State.AfterCharge:
		var new_velocity = (target - position).normalized() * delta * speed
		velocity = velocity.lerp(new_velocity, velocity_weight)
		
		if position.distance_squared_to(target) <= close_enough:
			start_idling()
			return
	
	position += velocity
	$AnimatedSprite2D.flip_h = velocity.x >= 0

func start_charging():
	current_state = State.PreparingCharge
	$AnimationPlayer.play("prepare_charge")
	await $AnimationPlayer.animation_finished
	
	current_state = State.Charge
	target = Globals.player.position
	var tween = create_tween()
	var acceleration_time = 1.0
	speed = 0.0
	tween.tween_property(self, "speed", charge_speed, acceleration_time)
	$AnimationPlayer.play("charge")

func run_away_after_charge():
	$AnimationPlayer.play_backwards("charge")
	current_state = State.AfterCharge
	speed = after_charge_speed
	target = Globals.current_level.get_random_fish_nav_point()

	# a bit of explanation here:
	# when fish reaches the charge target, it picks a random point and starts
	# moving towards that. However, to avoid sharp turns and make the movement
	# more fluid, we lerp between "go to current target"-velocity and "velocity
	# I had when I was charging", using this variable as weight
	velocity_weight = 0.0
	var tween = create_tween()
	var deceleration_time = 1.5
	tween.tween_property(self, "velocity_weight", 1.0, deceleration_time)

func start_idling():
	current_state = State.Idle
	speed = 0.0

	if braking_tween != null:
		braking_tween.kill()
	braking_tween = create_tween()
	var deceleration_time = 1.0
	braking_tween.set_ease(Tween.EASE_OUT)
	braking_tween.tween_property(self, "velocity", Vector2(0, 0), deceleration_time)
	
	var idle_time = randf_range(1.0, 4.0)
	await get_tree().create_timer(idle_time).timeout
	braking_tween.kill()
	
	if $Health.is_dead:
		return
	
	start_charging()

func _on_area_entered(other: Area2D) -> void:
	if other is Hitbox:
		other.health.take_damage(damage, self)

func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$HurtAnimations.stop()
	$HurtAnimations.play("hurt")

func _on_health_die() -> void:
	Globals.level.current_level.record_kill()

	$HurtAnimations.play("die")
	if braking_tween != null:
		braking_tween.kill()

	var tween = create_tween()
	tween.tween_property(self, "velocity", Vector2(0, 0), 1.0)
	await $HurtAnimations.animation_finished
	queue_free()
