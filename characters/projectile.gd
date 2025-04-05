class_name Projectile
extends Area2D

@export var point_at_velocity: bool = true
@export var fall_speed: float = 0.0
@export var damage: float = 1

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
	_on_body_entered(other)


func _on_body_entered(other: Node2D) -> void:
	var health = other.get_node_or_null("Health")
	if health is Health:
		health.health -= damage
	self.queue_free()
