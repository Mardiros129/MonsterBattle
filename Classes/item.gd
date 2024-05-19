extends StaticBody2D
#class_name Item


@export var item_name = ""
@onready var audio = $AudioStreamPlayer2D
@onready var audio_timeout = $AudioTimeout


func pickup():
	hide()
	additional_effect()
	audio.play()
	audio_timeout.start()


func additional_effect():
	pass


func _on_audio_timeout_timeout():
	queue_free()
