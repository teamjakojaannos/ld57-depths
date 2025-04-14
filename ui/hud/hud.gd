extends CanvasLayer


func _ready() -> void:
	Globals.player.gained_upgrade.connect(_on_player_gained_upgrade)


func _on_player_gained_upgrade(upgrade: Player.Upgrade) -> void:
	match upgrade:
		Player.Upgrade.UnlockHarpoonGun:
			$"HudRoot/PlayerStatus/Abilities/Harpoon_tip".visible = true
		Player.Upgrade.UnlockNetThrower:
			$"HudRoot/PlayerStatus/Abilities/Net_tip".visible = true
		Player.Upgrade.UnlockAnchorDropper:
			$"HudRoot/PlayerStatus/Abilities/Anchor_tip".visible = true
		_:
			pass
