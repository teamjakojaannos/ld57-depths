extends Node2D
class_name BossTentacle

@export var is_vertical: bool = false

func _ready() -> void:
	$Segments/Segment1/Hitbox.health = $"../../SquidBoss/Health"

func stop() -> void:
	$AnimationPlayer.stop()
	var tween = create_tween()
	tween.tween_property($Segments, "position", Vector2.LEFT * 590.0, 0.5)

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
