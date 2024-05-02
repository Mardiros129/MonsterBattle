extends Node2D


func _on_button_pressed():
	var inst = load("res://Levels/world.tscn").instantiate(false)
	get_tree().root.add_child(inst, false, 0)
	queue_free()
