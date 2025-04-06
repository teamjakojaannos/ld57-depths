extends CanvasLayer

func _on_leave_button_pressed() -> void:
	$"../UI_ShopMenu/Shopmenu_anim".play("Trans_out")

func _on_buy_button_pressed() -> void:
	$"../Buy_sound".play()
