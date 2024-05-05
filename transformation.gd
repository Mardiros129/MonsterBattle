extends Node2D


@onready var can_transform = false
@export var TransMon: PackedScene

func check_can_transform() -> bool:
	return false
