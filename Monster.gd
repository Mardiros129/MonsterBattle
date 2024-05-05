extends Node2D

@export var max_hp = 1
@onready var current_hp
@export var my_name = "null_name"
@export var speed = 0
@onready var level = 1

@onready var sprite2d = $Sprite2D
@onready var attack_node = $AttackNode

@onready var attack_list: Array

@export var type0: TypeList.Type
@export var type1: TypeList.Type

signal mon_dies
signal damage_enemy(dmg)
signal combat_message(message)
signal monster_transforms(trans_mon, index)


func _ready():
	current_hp = max_hp
	
	# Setup attacks
	for x in attack_node.get_child_count():
		attack_list.append(attack_node.get_child(x))

func attack(index, enemy_type0, enemy_type1):
	if attack_list[index] == null:
		pass
	else:
		var my_attack = attack_list[index]
		var attack_damage = my_attack.damage
		
		# Same-type attack bonus
		if type0 == my_attack.type || type1 == my_attack.type && my_attack.type != TypeList.Type.NONE:
			attack_damage *= 1.5
		
		# Multiply the damage by the type advantage for both types
		var multiplier0 = TypeList.TypeAdvantageChart[my_attack.type][enemy_type0]
		var multiplier1 = TypeList.TypeAdvantageChart[my_attack.type][enemy_type1]
		attack_damage *= multiplier0
		attack_damage *= multiplier1
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

func heal_damage(health:int):
	current_hp += health
	if current_hp > max_hp:
		current_hp = max_hp

func get_sprite():
	return sprite2d.texture

func transform_monster(trans_mon: PackedScene, index: int):
	print("oh! it's transforming")
	emit_signal("monster_transforms", trans_mon, index)

func check_transformation(index: int):
	var all_trans_options = find_child("TransformNode")
	if all_trans_options.get_child_count() > 0:
		for x in all_trans_options.get_child_count():
			var chosen_option = all_trans_options.get_child(x)
			if chosen_option.check_can_transform() == true:
				transform_monster(chosen_option.TransMon, index)
	else:
		print("no transformations exist")
