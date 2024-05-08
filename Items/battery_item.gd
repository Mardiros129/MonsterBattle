extends "res://item.gd"


func pickup():
	PlayerInventory.unique_items.append(item_name)
