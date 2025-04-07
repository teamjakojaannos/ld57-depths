extends Node2D
class_name Crabby

@export var min_attack_cooldown: float = 1.5
@export var max_attack_cooldown: float = 3.5

func _ready() -> void:
	get_tree().create_timer(2.5).timeout.connect(_start)
	Globals.current_level.kills_required = 1
	
	$DeadCrabby.visible = false
	
func _start() -> void:
	$AnimationPlayer.play("move")
	$AnimationPlayer.seek(0.5)
	$Sprite.play("default")

func _on_timer_left_timeout() -> void:
	$SnappyLeft.attack()
	$TimerLeft.start(randf_range(min_attack_cooldown, max_attack_cooldown))


func _on_timer_right_timeout() -> void:
	$SnappyRight.attack()
	$TimerRight.start(randf_range(min_attack_cooldown, max_attack_cooldown))


func _on_health_die() -> void:
	Globals.current_level.record_kill(15)
	var ded = $DeadCrabby
	ded.visible = true
	ded.play("default")
	ded.reparent(get_parent())
	queue_free()
