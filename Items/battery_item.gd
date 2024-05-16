extends "res://classes/item.gd"


func pickup():
	PlayerInventory.unique_items.append(item_name)
