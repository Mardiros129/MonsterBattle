extends Node2D

@export var max_hp = 1
@onready var current_hp
@export var my_name = "null_name"
@export var speed = 0

@onready var name_tag = $Name
@onready var hp_tag = $HP
@onready var type_tag = $Type
@onready var speed_tag = $Speed
@onready var attack_node = $AttackNode

@onready var attack_list: Array

@export var type1: TypeList.Type
@export var type2: TypeList.Type

signal mon_dies
signal damage_enemy(dmg)
signal combat_message(message)


func _ready():
	# UI elements
	current_hp = max_hp
	name_tag.text = my_name
	update_hp_tag()
	type_tag.text = TypeList.TypeName[type1]
	if type2 != TypeList.Type.NONE:
		type_tag.append_text("/" + TypeList.TypeName[type2])
	speed_tag.text = "Speed: " + str(speed)
	
	# Setup attacks
	for x in attack_node.get_child_count():
		attack_list.append(attack_node.get_child(x))

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
		var user_message = my_name + " used " + my_attack.attack_name
		
		if my_attack.damage > 0:
			user_message += "\n" + str(attack_damage) + " damage!"
			emit_signal("damage_enemy", attack_damage)
		if my_attack.healing > 0:
			user_message += "\n" + str(my_attack.healing) + " healed!"
			heal_damage(my_attack.healing)
			
		emit_signal("combat_message", user_message)
		return attack_damage

func take_damage(damage: int):
	current_hp -= damage
	update_hp_tag()

func heal_damage(health:int):
	current_hp += health
	if current_hp > max_hp:
		current_hp = max_hp
	update_hp_tag()

func update_hp_tag():
	hp_tag.text = str(current_hp) + "/" + str(max_hp) + " HP"
