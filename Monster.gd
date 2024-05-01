extends Node2D

@export var hp = 1
@export var my_name = "null_name"

@onready var name_tag = $Name
@onready var hp_tag = $HP
@onready var type_tag = $Type

@export var attack0: Node2D
@export var attack1: Node2D
@export var attack2: Node2D
@export var attack3: Node2D

@onready var attack_list: Array

@export var type1: TypeList.Type
@export var type2: TypeList.Type

signal mon_dies
signal damage_enemy(dmg)


func _ready():
	name_tag.text = my_name
	hp_tag.text = str(hp)
	type_tag.text = TypeList.TypeName[type1]
	if type2 != TypeList.Type.NONE:
		type_tag.append_text("/" + TypeList.TypeName[type2])
	
	attack_list.append(attack0)
	attack_list.append(attack1)
	attack_list.append(attack2)
	attack_list.append(attack3)

func attack(index):
	if attack_list[index] == null:
		pass
	else:
		var my_attack = attack_list[index]
		var attack_damage = my_attack.damage
		
		# Same-type attack bonus
		if type1 == my_attack.type || type2 == my_attack.type:
			attack_damage *= 1.5
		
		print(my_attack.attack_name)
		if my_attack.damage > 0:
			emit_signal("damage_enemy", attack_damage)
		if my_attack.healing > 0:
			heal_damage(my_attack.healing)
			print(str(my_attack.healing) + " healed!")

func take_damage(damage: int):
	hp -= damage
	hp_tag.text = str(hp)
	if hp <= 0:
		die()

func heal_damage(health:int):
	hp += health
	hp_tag.text = str(hp)

func die():
	mon_dies.emit()
	self.queue_free()
