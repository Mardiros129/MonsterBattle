extends Node2D
#class_name Effect


@export var animation_player: AnimationPlayer


func play_effect():
	if animation_player != null:
		animation_player.play("effect") # Anim must be named effect for it to play
	else:
		print("No animation player for effect " + self.name)
