extends Control
class_name ObjectiveOverlay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_objective(line1: String, line2: String, line3: String, anim_speed: float) -> void:
	visible = true

	$VBoxContainer/ObjectiveLine1.text = line1
	$VBoxContainer/ObjectiveLine2.text = line2
	$VBoxContainer/ObjectiveLine3.text = line3
	
	$AnimationPlayer.speed_scale = anim_speed
	$AnimationPlayer.play("enter")

	await $AnimationPlayer.animation_finished
	$AnimationPlayer.speed_scale = 1.0
	#if line3 != "":
	#	$AnimationPlayer.play("enter_3_lines")
	#elif line2 != "":
	#	$AnimationPlayer.play("enter_2_lines")
	#elif line1 != "":
	#	$AnimationPlayer.play("enter_1_line")
