extends Node2D

# characters/player.tscn
const PLAYER_SCENE: PackedScene = preload("uid://c7cixyoixeqxe")
const DEFAULT_PLAYER_SPAWN: Vector2 = Vector2.UP * 92.0


func ensure_player_exists() -> void:
	var player = _find_player()
	if player is Player:
		_fix_player_parent(player)
	else:
		player = _spawn_player()

	Globals.player = player


func _find_player() -> Player:
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player != null && !player.is_queued_for_deletion():
			return player

	return null


func _spawn_player() -> Player:
	var player = PLAYER_SCENE.instantiate()
	player.global_position = DEFAULT_PLAYER_SPAWN
	_fix_player_parent(player)

	return player


func _fix_player_parent(player: Player) -> void:
	if player.get_parent() == null:
		add_child(player)
	elif player.get_parent() != self:
		player.reparent(self)

	# Ensure the player is the last child. Should not have much effect on
	# anything, but is a nice added bit of consistency.
	move_child(player, -1)
