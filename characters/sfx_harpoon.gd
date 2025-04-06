extends AudioStreamPlayer


func _on_harpoon_gun_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	play()


func _on_net_thrower_fire(shooter: CharacterBody2D, direction: Vector2) -> void:
	play()
