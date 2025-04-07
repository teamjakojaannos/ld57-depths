extends HBoxContainer

func _ready() -> void:
	$Slider.value = Globals.music_volume_percent * 100.0

func _on_slider_value_changed(value: float) -> void:
	Globals.music_volume_percent = value / 100.0
	$Slider.release_focus()
