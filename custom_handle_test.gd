@tool
class_name CustomHandleTest
extends Node2D

@export var point := Vector2.ONE * 2.0

var gizmo: EditorTranslate2Gizmo


func _create_2d_gizmos(gizmos: EditorGizmos) -> void:
	gizmo = gizmos.translate_2d(point, _on_point_moved)


func _on_point_moved(new_position: Vector2) -> void:
	point = new_position
	gizmo.position = new_position
