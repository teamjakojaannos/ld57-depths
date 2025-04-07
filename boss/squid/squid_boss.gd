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
