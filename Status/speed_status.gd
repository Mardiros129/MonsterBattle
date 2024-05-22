extends "res://Classes/status.gd"


@export var speed_boost : int

func unique_effect():
	get_parent().get_parent().current_speed += speed_boost
