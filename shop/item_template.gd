extends TextureRect
class_name ShopItemUI

@onready var _name_label: Label = $Item_name
@onready var _price_label: Label = $Item_price
@onready var _picture: TextureRect = $Item_picture

@export var is_left: bool = false

var _item_name: String = ""
var _item_price: int = 42

func display_item(item: ShopItem) -> void:
	_item_name = item.name
	_item_price = item.price

	_picture.texture = item.picture
	_name_label.text = item.name
	if item.price > 0:
		_price_label.text = "%s" % item.price

func display_sold_out() -> void:
	# TODO
	pass


func _on_buy_button_pressed() -> void:
	if _item_name == "":
		return

	$"../..".handle_buy_item(_item_name, _item_price, is_left)
