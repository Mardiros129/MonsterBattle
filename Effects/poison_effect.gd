extends "res://effect.gd"


@export var damage = 5

# To do, change to signal
func activate_effect():
	print("poison damage!")
	get_parent().get_parent().take_damage(damage)
	timeout_effect()
