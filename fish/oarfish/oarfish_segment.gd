@tool
extends Node2D
class_name OarfishSegment

@export var distance_constraint: float = 10.0
@export var enable_nav_avoidance: bool = true:
	get:
		return enable_nav_avoidance
	set(value):
		enable_nav_avoidance = value
		_refresh.call_deferred()

@export var size: int = 12:
	get:
		return size
	set(value):
		size = value
		_refresh.call_deferred()

@export var sprite_gradient: Gradient = preload("uid://b70dp6v0tvogb")

func _ready() -> void:
	var gt = GradientTexture2D.new()
	$Sprite.texture = gt
	gt.gradient = sprite_gradient
	gt.width = size
	gt.height = size
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2.ONE * 0.5
	gt.fill_to = Vector2.ONE * 0.1

	_refresh()

func _refresh() -> void:
	var t = $Sprite.texture
	if t is GradientTexture2D:
		t.width = size
		t.height = size
	
	var avoidance: NavigationObstacle2D = $AvoidanceTarget
	if enable_nav_avoidance:
		avoidance.avoidance_enabled = true
		var hs = size * 0.5
		avoidance.vertices = PackedVector2Array([
			Vector2.UP * hs,
			Vector2.LEFT * hs,
			Vector2.DOWN * hs,
			Vector2.RIGHT * hs
		])
		avoidance.radius = hs
	else:
		avoidance.avoidance_enabled = false
		avoidance.vertices = PackedVector2Array()
		avoidance.radius = 0.0
