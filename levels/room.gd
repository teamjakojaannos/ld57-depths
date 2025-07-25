extends Node2D
class_name Room

signal Finished

const spike_fish_prefab = preload("res://fish/spiky_puffer_fish/spike_fish.tscn")

var entry_text: Array[String] = []

@export var no_blocker: bool = false

@onready var top_slot: Node2D = $"NavRoom/TopRoomPart"
@onready var bottom_slot: Node2D = $"NavRoom/BottomRoomPart"
@onready var left_slot: Node2D = $"NavRoom/LeftUtility"
@onready var right_slot: Node2D = $"NavRoom/RightUtility"

@onready var nav_region: NavigationRegion2D = $NavRoom

var bounds: Rect2:
	get:
		var width = 480.0
		var height = 300.0
		return Rect2(-width / 2.0, -height, width, height)

func finish() -> void:
	Finished.emit()

func unlock_exit() -> void:
	if get_node_or_null("Blocker") == null:
		return

	$Blocker.queue_free()
	Globals.trigger_room_clear()
	
	for child in left_slot.get_children():
		if child is BubbleElevator:
			child.enabled = false

	for child in right_slot.get_children():
		if child is BubbleElevator:
			child.enabled = false
	
func _ready() -> void:
	if no_blocker:
		unlock_exit()

	_prepare_nav()

func _prepare_nav() -> void:
	await get_tree().physics_frame
	$NavRoom.bake_navigation_polygon()

func is_in_navigable_region(pos: Vector2, threshold: float = 1.0) -> bool:
	var nav_map = nav_region.get_navigation_map()
	var closest_point = NavigationServer2D.map_get_closest_point(nav_map, pos)

	return closest_point.distance_squared_to(pos) < threshold * threshold


func get_random_fish_nav_point() -> Vector2:
	var nav_map = nav_region.get_navigation_map()
	var all_layers = 1
	var random_point = NavigationServer2D.map_get_random_point(nav_map, all_layers, true)
	return random_point
