extends Node2D

# game.tscn
const GAME_SCENE: PackedScene = preload("uid://bdtgjq516islk")

@onready var player_rig = $PlayerRig
@onready var level_root: Node2D = $NavRoom
@onready var nav_region: NavigationRegion2D = $NavRoom

var _current_scene: Node

signal initial_scene_ready


func start_game() -> void:
	get_tree().change_scene_to_packed(GAME_SCENE)
	if _current_scene != null:
		_current_scene.queue_free()

	# Wait one tick for the old scene unload. Current scene is now null.
	await get_tree().process_frame
	# Wait one tick for the new scene load. Current scene is now set.
	await get_tree().process_frame

	visible = true
	_current_scene = get_tree().current_scene
	_setup_initial_scene(_current_scene)

func restart_game(restore_checkpoint: bool) -> void:
	Globals._restoring_dying_state = restore_checkpoint
	UI.remove_hud()
	Globals.player.queue_free()
	Globals.player = null
	player_rig.ensure_player_exists()

	start_game()

func regenerate_navmesh() -> void:
	await get_tree().physics_frame
	nav_region.bake_navigation_polygon()

func _ready() -> void:
	var scene = get_tree().current_scene
	if scene != null:
		if !scene.is_in_group("non_game_scene"):
			_setup_initial_scene.call_deferred(scene)
		elif scene.is_in_group("main_scene"):
			_setup_for_intro()
			scene.get_node("Intro/IntroCamera").make_current()


func _setup_for_intro() -> void:
	visible = false


func _setup_initial_scene(scene: Node) -> void:
	scene.reparent(level_root)
	player_rig.ensure_player_exists()
	$PlayerRig/MainCamera.make_current()

	initial_scene_ready.emit()
