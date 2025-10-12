@tool
class_name CustomHandleTest
extends Node2D

@export var point := Vector2.ONE * 2.0


func _create_2d_gizmos() -> Array[Vector2]:
	return [point]
