extends Area2D
class_name TriggerHurt

@export var damage: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(other: Area2D) -> void:
	if other is Hitbox:
		other.health.take_damage_at(damage, self, global_position)
