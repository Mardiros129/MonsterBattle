extends Node2D


signal combat_message(message)

@export var status_name: String
@export var turn_timeout = 5
@export var effect : PackedScene


func get_status_name() -> String:
	return status_name

func activate_status():
	timeout_status()
	unique_effect()
	if effect != null:
		var new_effect = effect.instantiate()
		add_child(new_effect)
		new_effect.play_effect()


func unique_effect():
	pass

func timeout_status():
	turn_timeout -= 1
	if turn_timeout <= 0:
		self.queue_free()
