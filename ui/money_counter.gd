extends HBoxContainer

func _ready() -> void:
	Globals.money_changed.connect(update_label)
	update_label()

func update_label():
	$Label.text = "%s x" % Globals.money
