extends "res://classes/item.gd"


func pickup():
	PlayerInventory.catch_counter += 3
