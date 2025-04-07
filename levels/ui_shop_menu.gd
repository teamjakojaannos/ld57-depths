extends CanvasLayer

signal shop_closed
signal shop_open
signal item_bought(item: String, price: int)

@onready var _left_item_ui: ShopItemUI = $Control/Item_template
@onready var _right_item_ui: ShopItemUI = $Control/Item_template2

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
var _room_index_where_i_purchased_hp_potion = -1

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
	$"../ShopOpen_sound".play()
	
	_setup_items()
	
	_is_open = true
	shop_open.emit()

func _setup_items() -> void:
	var first_item = _get_next_item_in_queue()
	_left_item_ui.display_item(first_item)
	
	var hp_pot_already_bought = _room_index_where_i_purchased_hp_potion == Globals.current_room_index
	if hp_pot_already_bought:
		_right_item_ui.display_item(sold_out)
	else:
		_right_item_ui.display_item(health_potion)

func handle_buy_item(item_name: String, price: int, is_left: bool) -> void:
	if price < 0:
		return

	if Globals.money < price:
		_fail_buy(item_name, price, is_left)
	else:
		_success_buy(item_name, price)
		if is_left:
			var item = _get_next_item_in_queue()
			_left_item_ui.display_item(item)
		else:
			_room_index_where_i_purchased_hp_potion = Globals.current_room_index
			_right_item_ui.display_item(sold_out)

func _get_next_item_in_queue() -> ShopItem:
	var shop_queue: Array[ShopItem] = []
	
	var current_level = Globals.current_room_index
	if current_level >= 9:
		shop_queue.append(net_thrower)
	if current_level >= 16:
		shop_queue.append(anchor)
	if current_level >= 23:
		shop_queue.append(speed_upgrade_1)
	if current_level >= 28:
		shop_queue.append(harpoon_tier_2)
	if current_level >= 35:
		shop_queue.append(speed_upgrade_2)
	if current_level >= 42:
		shop_queue.append(harpoon_tier_3)
	if current_level >= 49:
		shop_queue.append(health_upgrade_1)
	
	shop_queue = shop_queue.filter(func(item: ShopItem): return !Globals.bought_upgrades.has(item.name))
	return shop_queue[0] if shop_queue.size() > 0 else sold_out

func _fail_buy(item_name: String, price: int, is_left: bool) -> void:
	print("Could not afford '%s' (cost %s, player has %s)" % [item_name, price, Globals.money])
	$"../NotEnoughMoney".play()
	var button = $Control/Item_template/Buy_button if is_left else $Control/Item_template2/Buy_button
	var tween = create_tween()
	tween.tween_property(button, "modulate", Color.RED, 0.1)
	tween.tween_property(button, "modulate", Color.WHITE, 0.1)
	tween.set_loops(2)

func _success_buy(item_name: String, price: int) -> void:
	var new_balance = Globals.money - price
	print("Item bought '%s' (cost %s, player has %s, new balance %s)" % [item_name, price, Globals.money, new_balance])
	$"../Buy_sound".play()
	Globals.money = new_balance
	item_bought.emit(item_name, price)
	
	Globals.handle_buy_item(item_name)
	

func _on_leave_button_pressed() -> void:
	close_shop()
