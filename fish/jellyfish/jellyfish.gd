extends Node2D

@export var min_speed = 10.0
@export var max_speed = 20.0
var speed = 0.0

@export var damage = 2
@export var charge_decay_per_second = 100.0
@export var charge_per_second = 50.0
@export var rest_time_after_explode = 2.0
var charge = 0.0
var ready_to_charge = true

var is_player_in_range = false
var player_hitbox: Hitbox

func _ready() -> void:
	speed = randf_range(min_speed, max_speed)

func _process(_delta: float) -> void:
	var alpha = clampf(charge, 0.0, 100.0) / 100.0
	$Glow.self_modulate = Color(1.0, 1.0, 1.0, alpha)

func _physics_process(delta: float) -> void:
	var target = Globals.player.position
	position = position.move_toward(target, delta * speed)
	
	if is_player_in_range && ready_to_charge:
		charge += charge_per_second * delta
		charge = min(charge, 200.0)
	else:
		charge -= charge_decay_per_second * delta
		charge = max(charge, 0.0)
	
	if charge >= 100.0:
		try_explode()

func try_explode():
	if player_hitbox == null:
		return
	
	$Sfx.play()
	
	charge = 0.0
	player_hitbox.health.take_damage(damage, self)
	ready_to_charge = false
	await get_tree().create_timer(rest_time_after_explode).timeout
	ready_to_charge = true

func _on_health_hurt() -> void:
	# stop current animation in case we have another hurt animation playing
	$HurtAnimations.stop()
	$HurtAnimations.play("hurt")

func _on_health_die() -> void:
	$HurtAnimations.play("die")
	await $HurtAnimations.animation_finished
	queue_free()

func _on_detection_area_entered(_area: Area2D) -> void:
	is_player_in_range = true

func _on_detection_area_exited(_area: Area2D) -> void:
	is_player_in_range = false

func _on_hurt_area_entered(hitbox: Area2D) -> void:
	if hitbox is Hitbox:
		player_hitbox = hitbox

func _on_hurt_area_exited(hitbox: Area2D) -> void:
	if hitbox is Hitbox:
		player_hitbox = null
