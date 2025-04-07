extends Node2D

func open() -> void:
	var tween = create_tween()
	tween.tween_property($Pivot, "position", Vector2.DOWN * 60.0, 1.5)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT_IN)
