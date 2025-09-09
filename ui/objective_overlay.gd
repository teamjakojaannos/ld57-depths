extends Control
class_name ObjectiveOverlay

signal show_objective_finished

func _ready() -> void:
	visible = false


func show_objective(
	line1: String,
	line2: String,
	line3: String,
	anim_speed: float,
	linger_duration: float = 0.0
) -> void:
	if visible:
		await show_objective_finished

	visible = true

	$VBoxContainer/ObjectiveLine1.text = line1
	$VBoxContainer/ObjectiveLine2.text = line2
	$VBoxContainer/ObjectiveLine3.text = line3

	$AnimationPlayer.play_section_with_markers(
		"enter",
		"", # Empty start marker => start from beginning
		"fully_visible",
		-1,
		anim_speed
	)

	await $AnimationPlayer.animation_finished

	if linger_duration > 0:
		await get_tree().create_timer(linger_duration).timeout

	$AnimationPlayer.play_section_with_markers(
		"enter",
		"fully_visible",
		"", # Empty end marker => play to end of the animation
		-1,
		anim_speed
	)

	await $AnimationPlayer.animation_finished

	visible = false
	$AnimationPlayer.stop()

	show_objective_finished.emit()
