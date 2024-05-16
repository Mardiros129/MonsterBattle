extends "res://Classes/interactible.gd"


@onready var dialog = $Dialog


func start_interaction():
	dialog.show()
	dialog_timer.start()


func _on_dialog_timer_timeout():
	dialog.hide()
