extends Node2D
#class_name Transformation


@onready var can_transform = false
@export var TransMon: PackedScene

func check_can_transform() -> bool:
	return false
