extends "res://effect.gd"


# To do, change to signal
func activate_effect():
	get_parent().get_parent().speed = 0
	print("it's stunned!")
