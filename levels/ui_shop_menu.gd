extends CanvasLayer

signal shop_closed
signal shop_open
signal item_bought(item: String, price: int)

@onready var _left_item_ui: ShopItemUI = $Control/Item_template
@onready var _right_item_ui: ShopItemUI = $Control/Item_template2

const sold_out: ShopItem = preload("uid://5aw8bapnh2tm")

var _is_open: bool = false

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
	_left_item_ui.display_item(load("uid://uaurhan33y31"))
	_right_item_ui.display_item(load("uid://b30ektrdokkl8"))

func handle_buy_item(item_name: String, price: int, is_left: bool) -> void:
	if price < 0:
		return

	if Globals.money < price:
		_fail_buy(item_name, price)
	else:
		_success_buy(item_name, price)
		if is_left:
			_left_item_ui.display_item(sold_out)
		else:
			_right_item_ui.display_item(sold_out)

func _fail_buy(item_name: String, price: int) -> void:
	print("Could not afford '%s' (cost %s, player has %s)" % [item_name, price, Globals.money])
	# TODO
	pass

func _success_buy(item_name: String, price: int) -> void:
	var new_balance = Globals.money - price
	print("Item bought '%s' (cost %s, player has %s, new balance %s)" % [item_name, price, Globals.money, new_balance])
	$"../Buy_sound".play()
	Globals.money = new_balance
	item_bought.emit(item_name, price)
	
	Globals.handle_buy_item(item_name)
	

func _on_leave_button_pressed() -> void:
	close_shop()
