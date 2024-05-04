extends Node2D


func go_to_world():
	var inst = load("res://Levels/world.tscn").instantiate(false)
	get_tree().root.add_child(inst, false, 0)
	queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			go_to_world()

func _on_button_pressed():
	go_to_world()
