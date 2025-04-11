extends Node

const HUD_SCENE: PackedScene = preload("uid://c21kxdgros7ub")

@onready var _overlay_layer: CanvasLayer = $Overlay
@onready var _pause_menu_layer: CanvasLayer = $PauseMenuLayer
var _hud_layer: CanvasLayer

@onready var _objective_overlay: ObjectiveOverlay = $Overlay/ObjectiveOverlay

var objective_overlay: ObjectiveOverlay:
	get:
		return _objective_overlay


func remove_hud() -> void:
	if _hud_layer is CanvasLayer:
		_hud_layer.queue_free()
		_hud_layer = null


func _ready() -> void:
	var scene = get_tree().current_scene
	if scene != null && scene.is_in_group("main_scene"):
		_hide()
	
	LevelRig.initial_scene_ready.connect(_setup)


func _hide() -> void:
	_overlay_layer.hide()
	_pause_menu_layer.hide()
	if _hud_layer is CanvasLayer:
		_hud_layer.hide()


func _setup() -> void:
	_overlay_layer.show()
	_pause_menu_layer.show()

	if _hud_layer is CanvasLayer:
		_hud_layer.show()
	else:
		_hud_layer = HUD_SCENE.instantiate()
		add_child(_hud_layer)
