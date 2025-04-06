extends Area2D

@export var damage = 2
@export var charge_speed = 200.0
@export var after_charge_speed = 100.0
var speed = 0.0

var velocity = Vector2()

enum State {
	Idle,
	Charge,
	AfterCharge,
}

var current_state = State.Idle
var charge_target = Vector2()
# little explanation here: when the fish reaches the charge target, we save
# the velocity it had to this variable. Then it starts moving towards some
# random spot (the well named "after charge target"). However, in order to avoid
# sharp turns, we lerp the fish's velocity between "velocity fish had when it charged"
# and "new velocity that takes fish to the new target" with "velocity weight" which
# is simply tweened from 0->1 over some duration
# In other words, acceleration...
var final_charge_velocity = Vector2()
var after_charge_target = Vector2()
var velocity_weight = 0.0

func _ready() -> void:
	start_idling()

func _physics_process(delta: float) -> void:
	var close_enough = 10.0
	
	if current_state == State.Charge:
		velocity = (charge_target - position).normalized() * delta * speed

		if position.distance_squared_to(charge_target) <= close_enough:
			run_away_after_charge(velocity)
			return
	
	if current_state == State.AfterCharge:
		var new_velocity = (after_charge_target - position).normalized() * delta * speed
		velocity = final_charge_velocity.lerp(new_velocity, velocity_weight)
		
		if position.distance_squared_to(after_charge_target) <= close_enough:
			start_idling()
			return
	
	position += velocity
	$AnimatedSprite2D.flip_h = velocity.x >= 0

func start_charging():
	current_state = State.Charge
	charge_target = Globals.player.position
	var tween = create_tween()
	var acceleration_time = 1.0
	tween.tween_property(self, "speed", charge_speed, acceleration_time)

func run_away_after_charge(charge_velocity: Vector2):
	current_state = State.AfterCharge
	speed = after_charge_speed
	after_charge_target = Globals.current_level.get_random_fish_nav_point()
	final_charge_velocity = charge_velocity

	velocity_weight = 0.0
	var tween = create_tween()
	var deceleration_time = 1.5
	tween.tween_property(self, "velocity_weight", 1.0, deceleration_time)

func start_idling():
	current_state = State.Idle
	var tween = create_tween()
	var deceleration_time = 1.0
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "velocity", Vector2(0, 0), deceleration_time)
	
	var idle_time = randf_range(1.0, 4.0)
	await get_tree().create_timer(idle_time).timeout
	
	tween.kill()
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
	var tween = create_tween()
	tween.tween_property(self, "speed", 0.0, 1.0)
	await $HurtAnimations.animation_finished
	queue_free()
