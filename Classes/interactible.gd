extends StaticBody2D


@onready var facing = false
@onready var nametag = $Nametag
@onready var dialog_timer = $DialogTimer


func start_interaction():
	pass


func _unhandled_input(event):
	if event.is_action_pressed("accept") and facing:
		start_interaction()


func _on_area_2d_area_entered(area):
	facing = true


func _on_area_2d_area_exited(area):
	facing = false

