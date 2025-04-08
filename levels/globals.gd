extends Node
class_name GameGlobals

@export var depth: float = 0.0
@export var current_room_index: int = 0:
	get:
		return current_room_index
	set(value):
		var old = current_room_index
		current_room_index = value
		if old != value:
			stage_changed.emit()

		if value > 2:
			tutorial_cleared = true

var tutorial_cleared: bool = false

signal stage_changed

@export var player: Player
@export var level: EndlessLevel
@export var current_level: Level

var money_at_start = 0
var money_at_checkpoint = 0
var _restoring_dying_state: bool = false

var _money: int = money_at_start
var money: int :
	get:
		return _money
	set(value):
		_money = value
		money_changed.emit()

@export var music: Jukebox

var _music_volume_percent: float = 0.5
var music_volume_percent: float:
	get:
		return _music_volume_percent
	set(value):
		_music_volume_percent = clampf(value, 0.0, 1.0)
		volume_changed.emit()

var bought_upgrades: Array[String] = []

signal level_cleared
signal volume_changed
signal money_changed

func _ready() -> void:
	reset()

func reset() -> void:
	if _restoring_dying_state:
		_restoring_dying_state = false

		# "restore previous checkpoint"
		if current_room_index >= 48:
			current_room_index = 48
		elif current_room_index >= 41:
			current_room_index = 42
		elif current_room_index >= 34:
			current_room_index = 35
		elif current_room_index >= 27:
			current_room_index = 28
		elif current_room_index >= 22:
			current_room_index = 23
		elif current_room_index >= 15:
			current_room_index = 16
		elif current_room_index >= 8:
			current_room_index = 9
		elif tutorial_cleared:
			current_room_index = 2

		_replay_upgrades.call_deferred()
	else:
		depth = 0.0
		current_room_index = 0
		money = money_at_start
		bought_upgrades.clear()

func _replay_upgrades() -> void:
	money = money_at_checkpoint
	var uppies = bought_upgrades.duplicate()
	bought_upgrades.clear()
	for item in uppies:
		handle_buy_item(item)

func trigger_level_clear() -> void:
	level_cleared.emit()


func handle_buy_item(item_name: String) -> void:
	match item_name:
		"Anchor weapon":
			player.unlock_anchor_dropper()
		"Net weapon":
			player.unlock_net_thrower()
		"Harpoon gun +1":
			player.upgrade_harpoon_gun(1)
		"Harpoon gun +2":
			player.upgrade_harpoon_gun(2)
		"Health Potion":
			player.heal_to_full()
		"Max health +1":
			player.upgrade_max_health(1)
		"Max Health +2":
			player.upgrade_max_health(2)
		"Max Health +3":
			player.upgrade_max_health(3)
		"Speed +1":
			player.upgrade_speed(1)
		"Speed +2":
			player.upgrade_speed(2)
		"Speed +3":
			player.upgrade_speed(3)
		"Sold out":
			pass
		_:
			push_error("UNHANDLED ITEM %s" % item_name)
	
	
	if item_name != "Sold out" && item_name != "Health Potion":
		bought_upgrades.append(item_name)
