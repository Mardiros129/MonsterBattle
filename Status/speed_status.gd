extends "res://status.gd"


@export var speed_boost = 10

func activate_status():
	get_parent().get_parent().current_speed += speed_boost
