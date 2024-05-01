extends Node2D

@export var max_hp = 1
@onready var current_hp
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
	current_hp = max_hp
	name_tag.text = my_name
	update_hp_tag()
	type_tag.text = TypeList.TypeName[type1]
	if type2 != TypeList.Type.NONE:
		type_tag.append_text("/" + TypeList.TypeName[type2])
	
	if attack0 != null:
		attack_list.append(attack0)
	if attack1 != null:
		attack_list.append(attack1)
	if attack2 != null:
		attack_list.append(attack2)
	if attack3 != null:
		attack_list.append(attack3)

func attack(index, enemy_type1, enemy_type2):
	if attack_list[index] == null:
		pass
	else:
		var my_attack = attack_list[index]
		var attack_damage = my_attack.damage
		
		# Same-type attack bonus
		if type1 == my_attack.type || type2 == my_attack.type && my_attack.type != TypeList.Type.NONE:
			attack_damage *= 1.5
		
		# Multiply the damage by the type advantage for both types
		var multiplier1 = TypeList.TypeAdvantageChart[my_attack.type][enemy_type1]
		var multiplier2 = TypeList.TypeAdvantageChart[my_attack.type][enemy_type2]
		attack_damage *= multiplier1
		attack_damage *= multiplier2
		# Round up to the nearest whole number (ensures attacks always do minimum 1 damage)
		attack_damage = snapped(attack_damage, 1.0)
		
		# Finish the attack
		print(my_attack.attack_name)
		if my_attack.damage > 0:
			print(str(attack_damage) + " damage!")
			emit_signal("damage_enemy", attack_damage)
		if my_attack.healing > 0:
			heal_damage(my_attack.healing)
			print(str(my_attack.healing) + " healed!")
		
		return attack_damage

func take_damage(damage: int):
	current_hp -= damage
	update_hp_tag()
	if current_hp <= 0:
		die()

func heal_damage(health:int):
	current_hp += health
	if current_hp > max_hp:
		current_hp = max_hp
	update_hp_tag()

func die():
	mon_dies.emit()

func update_hp_tag():
	hp_tag.text = str(current_hp) + "/" + str(max_hp) + " HP"
