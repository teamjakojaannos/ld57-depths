extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if player is Player:
		player.unlock_harpoon_gun()
		UI.objective_overlay.show_objective("Z", "TO", "KILL", 0.5)
		queue_free()
