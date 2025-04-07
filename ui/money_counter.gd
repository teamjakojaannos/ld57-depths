extends HBoxContainer

var money_tween: Tween
var current_value = 0

func _ready() -> void:
	Globals.money_changed.connect(update_label)
	set_label_text(Globals.money)

func update_label():
	if money_tween != null:
		money_tween.kill()
	
	money_tween = create_tween()
	var time = 1.0
	money_tween.tween_method(set_label_text, current_value, Globals.money, time)


func set_label_text(value: int):
	current_value = value
	$Label.text = "%s x" % current_value
