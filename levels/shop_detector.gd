extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		$"../UI_ShopMenu/Shopmenu_anim".play("Trans_in")
		$"../ShopOpen_sound".play()
