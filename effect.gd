extends Node2D

@export var effect_name: String
@export var turn_timeout = 5


func get_effect_name() -> String:
	return effect_name

func activate_effect():
	pass

func timeout_effect():
	turn_timeout -= 1
	if turn_timeout <= 0:
		self.queue_free()
