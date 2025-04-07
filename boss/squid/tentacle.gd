extends Node2D
class_name BossTentacle

@export var is_vertical: bool = false

func _ready() -> void:
	$Segments/Segment1/Hitbox.health = $"../../SquidBoss/Health"

func peek() -> void:
	if is_vertical:
		$AnimationPlayer.play("peek")
	else:
		$AnimationPlayer.play("peek")

func attack() -> void:
	if is_vertical:
		$AnimationPlayer.play("emerge_little")
	else:
		$AnimationPlayer.play("emerge")

func retract() -> void:
	if is_vertical:
		$AnimationPlayer.play("retract_little")
	else:
		$AnimationPlayer.play("retract")
