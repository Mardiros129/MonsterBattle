extends "res://Classes/status.gd"


@export var poison_damage_attack : PackedScene
@export var damage = 5

func unique_effect():
	print("poison damage!")
	var poison_damage = poison_damage_attack.instantiate()
	# Is there a way to do this without calling get_parent twice?
	var monster = get_parent().get_parent()
	monster.take_damage(damage)
