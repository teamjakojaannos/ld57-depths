extends Node
class_name GameGlobals

@export var depth: float = 0.0
@export var current_room_index: int = 0:
	get:
		return current_room_index
	set(value):
		current_room_index = value
		if value > 2:
			tutorial_cleared = true
var tutorial_cleared: bool = false

@export var player: Player
@export var level: EndlessLevel
@export var current_level: Level

var money_at_start = 100

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
	

signal level_cleared
signal volume_changed
signal money_changed

func _ready() -> void:
	reset()

func reset() -> void:
	depth = 0.0
	current_room_index = 2 if tutorial_cleared else 0
	money = money_at_start

func trigger_level_clear() -> void:
	level_cleared.emit()


func handle_buy_item(item_name: String) -> void:
	match item_name:
		"Anchor":
			player.unlock_anchor_dropper()
		"Fishing Net":
			player.unlock_net_thrower()
		"Sold out":
			pass
		_:
			push_error("UNHANDLED ITEM %s" % item_name)
