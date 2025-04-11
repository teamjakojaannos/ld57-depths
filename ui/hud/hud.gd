extends CanvasLayer


func _ready() -> void:
	Globals.player.gained_upgrade.connect(_on_player_gained_upgrade)


func _on_player_gained_upgrade(upgrade: Player.Upgrade) -> void:
	match upgrade:
		Player.Upgrade.UnlockHarpoonGun:
			$Harpoon_tip.visible = true
		Player.Upgrade.UnlockNetThrower:
			$Net_tip.visible = true
		Player.Upgrade.UnlockAnchorDropper:
			$Anchor_tip.visible = true
		_:
			pass
