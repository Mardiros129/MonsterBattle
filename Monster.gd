extends Sprite2D

@export var hp = 1
@export var my_name = "null_name"

@onready var name_tag = $Name
@onready var hp_tag = $HP


func _ready():
	name_tag.text = my_name
	hp_tag.text = str(hp)

func take_damage(damage: int):
	hp -= damage
	hp_tag.text = str(hp)
	if hp <= 0:
		die()

func heal_damage(health:int):
	hp += health
	hp_tag.text = str(hp)

func die():
	self.queue_free()
