extends "res://status.gd"


# To do, change to signal
func activate_status():
	get_parent().get_parent().speed = 0
	print("it's stunned!")
