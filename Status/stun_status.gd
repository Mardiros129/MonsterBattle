extends "res://Classes/status.gd"


func unique_effect():
	get_parent().get_parent().current_speed = 0
	print("it's stunned!")
