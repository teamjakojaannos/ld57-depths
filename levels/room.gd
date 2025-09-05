extends Node2D
class_name Room

signal finished

var entry_text: Array[String] = []

var nav_region: NavigationRegion2D:
	get:
		return LevelRig.nav_region

var bounds: Rect2:
	get:
		var width = 480.0
		var height = 300.0
		return Rect2(-width / 2.0, -height, width, height)

func finish() -> void:
	finished.emit()

func unlock_exit() -> void:
	if get_node_or_null("Blocker") == null:
		return

	$Blocker.queue_free()
	Globals.trigger_room_clear()


func is_in_navigable_region(pos: Vector2, threshold: float = 1.0) -> bool:
	var nav_map = nav_region.get_navigation_map()
	var closest_point = NavigationServer2D.map_get_closest_point(nav_map, pos)

	return closest_point.distance_squared_to(pos) < threshold * threshold


func get_random_fish_nav_point() -> Vector2:
	var nav_map = nav_region.get_navigation_map()
	var all_layers = 1
	var random_point = NavigationServer2D.map_get_random_point(nav_map, all_layers, true)
	return random_point
