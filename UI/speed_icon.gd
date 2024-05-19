extends Control


@onready var hint = $Hint


func _on_mouse_entered():
	hint.show()


func _on_mouse_exited():
	hint.hide()
