extends CanvasLayer

signal shop_closed
signal shop_open
signal item_bought(item: String, price: int)

@onready var _left_item_ui: ShopItemUI = $Control/Item_template
@onready var _right_item_ui: ShopItemUI = $Control/Item_template2

@onready var _buy_success_sound: AudioStreamPlayer = $BuySuccess
@onready var _buy_failed_sound: AudioStreamPlayer = $BuyFailed

const sold_out: ShopItem = preload("uid://5aw8bapnh2tm")
const health_potion: ShopItem = preload("res://shop/items/Health_potion.tres")

const net_thrower: ShopItem = preload("res://shop/items/net_thrower.tres")
const anchor: ShopItem = preload("res://shop/items/anchor.tres")
const harpoon_tier_2: ShopItem = preload("res://shop/items/harpoon_t2.tres")
const harpoon_tier_3: ShopItem = preload("res://shop/items/harpoon_t3.tres")

const speed_upgrade_1: ShopItem = preload("res://shop/items/upgrade_speed.tres")
const speed_upgrade_2: ShopItem = preload("res://shop/items/upgrade_speed2.tres")
const speed_upgrade_3: ShopItem = preload("res://shop/items/upgrade_speed3.tres")

const health_upgrade_1: ShopItem = preload("res://shop/items/upgrade_health.tres")
const health_upgrade_2: ShopItem = preload("res://shop/items/Upgrade_health2.tres")
const health_upgrade_3: ShopItem = preload("res://shop/items/Upgrade_health3.tres")


var _is_open: bool = false

var left_queue: Array[ShopItem] = []
var right_queue: Array[ShopItem] = []
var _generated_queues_room_index = -1

func close_shop() -> void:
	if !_is_open:
		return

	$Shopmenu_anim.clear_queue()
	if !$Shopmenu_anim.current_animation == "Trans_out":
		$Shopmenu_anim.queue("Trans_out")

	_is_open = false
	shop_closed.emit()

func open_shop() -> void:
	$Shopmenu_anim.clear_queue()
	if !$Shopmenu_anim.current_animation == "Trans_in":
		$Shopmenu_anim.queue("Trans_in")

	_setup_items()

	_is_open = true
	shop_open.emit()

func _setup_items() -> void:
	var already_generated = _generated_queues_room_index == Globals.current_room_index
	if already_generated:
		return

	_generated_queues_room_index = Globals.current_room_index

	var p = Globals.player
	var hp_percent = p.get_health() / p.get_max_health()
	var is_almost_full_hp = hp_percent > 0.80

	if is_almost_full_hp:
		var stat_upgrade = _get_next_stat_upgrade()
		if stat_upgrade != null:
			right_queue = [stat_upgrade, health_potion]
		else:
			right_queue = [health_potion]
		# hopefully my code works and the stat upgrade gets removed from left queue
		# so its not in both queues
		left_queue = _get_upgrade_queue(stat_upgrade)
	else:
		right_queue = [health_potion]
		left_queue = _get_upgrade_queue()

	_left_item_ui.display_item(_get_first_item_in_queue(left_queue))
	_right_item_ui.display_item(_get_first_item_in_queue(right_queue))

func _get_next_stat_upgrade():
	var upgrades: Array[ShopItem] = [speed_upgrade_1, health_upgrade_1, speed_upgrade_2, health_upgrade_2, speed_upgrade_3, health_upgrade_3]
	var not_bought = _remove_already_obtained(upgrades)
	return null if not_bought.is_empty() else not_bought[0]

func handle_buy_item(item_name: String, price: int, is_left: bool) -> void:
	if price < 0:
		return

	if Globals.money < price:
		_fail_buy(item_name, price, is_left)
	else:
		_success_buy(item_name, price)
		if is_left:
			var item = _remove_first_item_and_get_next_item_in_queue(left_queue)
			_left_item_ui.display_item(item)
		else:
			var item = _remove_first_item_and_get_next_item_in_queue(right_queue)
			_right_item_ui.display_item(item)


func _get_first_item_in_queue(queue: Array[ShopItem]) -> ShopItem:
	return sold_out if queue.is_empty() else queue[0]

func _remove_first_item_and_get_next_item_in_queue(queue: Array[ShopItem]) -> ShopItem:
	if queue.size() > 0:
		queue.remove_at(0)

	return sold_out if queue.is_empty() else queue[0]

func _get_upgrade_queue(stat_upgrade_in_right_queue: ShopItem = null) -> Array[ShopItem]:
	var shop_queue: Array[ShopItem] = []

	var current_level = Globals.current_room_index
	if current_level >= 9:
		shop_queue.append(net_thrower)
	if current_level >= 16:
		shop_queue.append(anchor)
	if current_level >= 28:
		shop_queue.append(harpoon_tier_2)
	if current_level >= 35:
		shop_queue.append(speed_upgrade_2)
	if current_level >= 42:
		shop_queue.append(harpoon_tier_3)
	# we offer this upgrade earlier, but if the player doesn't buy it, we prioritize
	# offering weapon upgrades in later stages
	# TODO: do similar stuff for other non-weapon upgrades
	if current_level >= 23:
		shop_queue.append(speed_upgrade_1)
	if current_level >= 49:
		shop_queue.append(health_upgrade_1)
		shop_queue.append(health_upgrade_2)
		shop_queue.append(health_upgrade_3)
		shop_queue.append(speed_upgrade_2)
		shop_queue.append(speed_upgrade_3)

	if stat_upgrade_in_right_queue != null:
		# avoid duplicate upgrades
		shop_queue = shop_queue.filter(func(item: ShopItem): return item.name != stat_upgrade_in_right_queue.name)

	return _remove_already_obtained(shop_queue)

func _fail_buy(item_name: String, price: int, is_left: bool) -> void:
	print("Could not afford '%s' (cost %s, player has %s)" % [item_name, price, Globals.money])
	_buy_failed_sound.play()

	var button = $Control/Item_template/Buy_button if is_left else $Control/Item_template2/Buy_button
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.RED, 0.1)
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)
	tween.set_loops(2)

func _success_buy(item_name: String, price: int) -> void:
	var new_balance = Globals.money - price
	print("Item bought '%s' (cost %s, player has %s, new balance %s)" % [item_name, price, Globals.money, new_balance])
	_buy_success_sound.play()

	Globals.money = new_balance
	item_bought.emit(item_name, price)

	Globals.handle_buy_item(item_name)

func _remove_already_obtained(items: Array[ShopItem]) -> Array[ShopItem]:
	return items.filter(func(item: ShopItem): return !Globals.bought_upgrades.has(item.name))

func _on_leave_button_pressed() -> void:
	close_shop()
