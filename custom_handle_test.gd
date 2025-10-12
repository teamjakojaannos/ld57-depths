@tool
class_name CustomHandleTest
extends Node2D

@export var point := Vector2.ONE * 2.0


func _create_2d_gizmos(gizmos: EditorGizmos) -> void:
	print("_create_2d_gizmos")
	var _point_translate_gizmo := gizmos.translate_2d(point)
	var _point_translate_gizmo_static := gizmos.translate_2d(Vector2.RIGHT * 100.0)
