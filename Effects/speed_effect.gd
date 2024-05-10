extends "res://effect.gd"


@export var speed_boost = 10

func activate_effect():
	get_parent().get_parent().current_speed += speed_boost
