extends Node2D

@export var status_name: String
@export var turn_timeout = 5


func get_status_name() -> String:
	return status_name

func activate_status():
	pass

func timeout_status():
	turn_timeout -= 1
	if turn_timeout <= 0:
		self.queue_free()
