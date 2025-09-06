@tool
extends Node2D
class_name Room

signal finished

# background.tscn - the scene with scrolling walls / fishes etc.
const _background_scene = preload("uid://bj0y1grmkuw1b")
var _debug_background_instance: Node = null

## If set, forces the next room to be generated using this specific room scene.
## Useful for e.g. boss sequences spanning multiple rooms, or shop, etc. special
## sequences.
##
## Root node of the selected scene should be a Room.
@export
var next_room: PackedScene

@export_group("Debug")
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_NO_INSTANCE_STATE)
var preview_game_background: bool = false:
	get:
		return _debug_background_instance != null
	set(value):
		_show_game_background.call_deferred(value)

@export
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

func _show_game_background(background_visible: bool):
	if _debug_background_instance != null:
		_debug_background_instance.queue_free()
		_debug_background_instance = null

	if background_visible:
		_debug_background_instance = null
		_debug_background_instance = _background_scene.instantiate()
		add_child(_debug_background_instance)
