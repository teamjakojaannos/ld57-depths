@tool
class_name EditorTranslate2Gizmo
extends EditorGizmo

signal moved(new_pos: Vector2)

var position: Vector2


func _init(position: Vector2) -> void:
	self.position = position


func _draw() -> void:
	draw_circle(position, 5.0, Color.NAVY_BLUE, true)
	draw_circle(position, 100.0, Color.DEEP_SKY_BLUE, false, 2)
