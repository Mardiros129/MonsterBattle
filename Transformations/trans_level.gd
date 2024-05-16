extends "res://classes/transformation.gd"


@export var level_req: int

func check_can_transform() -> bool:
	var monster = get_parent().get_parent()
	if monster.level >= level_req:
		print("can transform")
		return true
	else:
		print("cannot transform")
		return false
	return false
