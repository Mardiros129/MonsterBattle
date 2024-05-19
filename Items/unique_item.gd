extends "res://classes/item.gd"


func additional_effect():
	PlayerInventory.unique_items.append(item_name)
