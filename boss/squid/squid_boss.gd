extends Node2D

var large = preload("uid://dkgpgoo61sytr")
var small = preload("uid://c474x6njkbh5m")
var tiny = preload("uid://b2klgm83ir3fd")

func _on_health_hurt_at(pos: Vector2) -> void:
	var prefab = tiny
	if abs(pos.x - 5.0) < 25.0:
		if pos.y > -50.0:
			prefab = large
		else:
			prefab = small

	var emitter: Node2D = prefab.instantiate()
	emitter.global_position = pos
	Globals.level.current_level.add_child(emitter)


func _on_health_die() -> void:
	$"../Tentacles".retract_all()
	$AnimationPlayer.stop()
	$AnimationPlayer2.stop()
	$"../HAttackTimer".stop()
	$"../VAttackTimer".stop()
	
	var tween = create_tween()
	var current = global_position
	var goal = current + Vector2.DOWN * 150.0
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "global_position", goal, 1.5)
	
	var goal2 = $"../Tentacles".global_position + Vector2.DOWN * 1000.0
	tween.tween_property($"../Tentacles", "global_position", goal2, 5.0)
	
	await tween.finished
	await Globals.level.objective_overlay.show_objective("YOU", "ARE", "VICTORIOUS", 0.5)
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://levels/game.tscn")
