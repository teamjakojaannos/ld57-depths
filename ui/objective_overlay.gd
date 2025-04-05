extends Control
class_name ObjectiveOverlay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_objective(line1: String, line2: String, line3: String) -> void:
	visible = true

	$VBoxContainer/ObjectiveLine1.text = line1
	$VBoxContainer/ObjectiveLine2.text = line2
	$VBoxContainer/ObjectiveLine3.text = line3
	
	$AnimationPlayer.play("enter")
