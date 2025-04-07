extends TextureRect
class_name ShopItemUI

@onready var _name_label: Label = $Item_name
@onready var _price_label: Label = $Item_price
# @onready var _picture: TextureRect = $Item_picture

var _item_name: String = ""
var _item_price: int = 42

func display_item(item_name: String, price: int) -> void:
	_item_name = item_name
	_item_price = price

	_name_label.text = item_name
	_price_label.text = "%s" % price

func display_sold_out() -> void:
	# TODO
	pass


func _on_buy_button_pressed() -> void:
	if _item_name == "":
		return

	$"../..".handle_buy_item(_item_name, _item_price)
