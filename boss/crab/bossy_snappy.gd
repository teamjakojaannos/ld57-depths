extends Node2D
class_name SnappyLeft


func attack() -> void:
	$AnimationPlayer.play("attack")
	$AnimationPlayer.queue("snappy")
