extends CanvasLayer

signal shop_closed
signal shop_open
signal item_bought(item: String, price: int)

@onready var _left_item_ui: ShopItemUI = $Control/Item_template
@onready var _right_item_ui: ShopItemUI = $Control/Item_template2

func close_shop() -> void:
	$Shopmenu_anim.clear_queue()
	if !$Shopmenu_anim.current_animation == "Trans_out":
		$Shopmenu_anim.queue("Trans_out")
	shop_closed.emit()

func open_shop() -> void:
	$Shopmenu_anim.clear_queue()
	if !$Shopmenu_anim.current_animation == "Trans_in":
		$Shopmenu_anim.queue("Trans_in")
	$"../ShopOpen_sound".play()
	
	_setup_items()

func _setup_items() -> void:
	_left_item_ui.display_item("Frankin kalsarit", 666)
	_right_item_ui.display_item("Painis Cupcake", 69)

func handle_buy_item(item_name: String, price: int) -> void:
	if Globals.money < price:
		_fail_buy(item_name, price)
	else:
		_success_buy(item_name, price)

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

func _on_leave_button_pressed() -> void:
	close_shop()
