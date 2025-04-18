extends Control

var tween: Tween

func _ready() -> void:
	Globals.player.Hurt.connect(update_indicator)
	Globals.player.Heal.connect(update_indicator)
	update_indicator()

func update_indicator():
	var hp = Globals.player.get_health()
	var max_hp = Globals.player.get_max_health()
	
	var angle_at_empty = -130
	var angle_at_full = 130
	
	var percent = hp / max_hp if max_hp != 0 else 0
	var full_range = angle_at_full - angle_at_empty
	var angle = full_range * percent + angle_at_empty
	
	if tween != null:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property($Hand, "rotation_degrees", angle, 0.5)
