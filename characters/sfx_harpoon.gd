extends AudioStreamPlayer


func _on_harpoon_gun_fire(_shooter: CharacterBody2D, _direction: Vector2) -> void:
	play()


func _on_net_thrower_fire(_shooter: CharacterBody2D, _direction: Vector2) -> void:
	play()
