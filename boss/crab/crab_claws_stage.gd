extends Node2D

@export var both_chance: float = 0.15

var _attacks_in_progress: int = 0

func _ready() -> void:
	get_tree().create_timer(1.5).timeout.connect(attack)
	
	Globals.level_cleared.connect(_on_level_cleared)

func _on_level_cleared() -> void:
	$Timer.stop()
	_attacks_in_progress = 9999
	$SnappyLeft.retreat()
	$SnappyRight.retreat()
	
	var elevator = get_node_or_null("../BubbleElevator")
	if elevator is BubbleElevator:
		elevator.enabled = false

func attack() -> void:
	var f = randf()
	if f < both_chance:
		_attacks_in_progress = 2
		$SnappyLeft.attack()
		$SnappyRight.attack()
	elif randf() < 0.5:
		_attacks_in_progress = 1
		$SnappyLeft.attack()
	else:
		_attacks_in_progress = 1
		$SnappyRight.attack()


func _on_timer_timeout() -> void:
	attack()


func _on_snappy_left_attack_finished() -> void:
	_attacks_in_progress -= 1

	if _attacks_in_progress == 0:
		$Timer.start()


func _on_snappy_right_attack_finished() -> void:
	_attacks_in_progress -= 1
	
	if _attacks_in_progress == 0:
		$Timer.start()
