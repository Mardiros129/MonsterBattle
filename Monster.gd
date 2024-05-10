extends Node2D


@export var my_name = "null_name"
@export var max_hp = 1
@export var strength = 1 #physical damage
@export var intelligence = 1 #magic damage
@export var defense = 1 #physical defense
@export var resistance = 1 #magic defense
@export var speed = 1
@onready var current_speed

@export var level = 1
@export var level_max = 10
@export var level_hp_bonus = 10
@export var level_str_bonus = 1
@export var level_int_bonus = 1
@export var level_def_bonus = 1
@export var level_res_bonus = 1
@export var level_spd_bonus = 1

@onready var current_hp
@export var experience = 0 # Doesn't seem to save the number unless it's an export var

@onready var sprite2d = $Sprite2D
@onready var attack_node = $AttackNode
@onready var transform_node = $TransformNode
@onready var effect_node = $EffectNode

@onready var attack_list: Array

@export var type0: TypeList.Type
@export var type1: TypeList.Type

signal monster_transforms(trans_mon, index)


func _ready():
	current_hp = max_hp
	current_speed = speed
	
	# Setup attacks
	for x in attack_node.get_child_count():
		attack_list.append(attack_node.get_child(x))

func attack(index, target):
	if attack_list[index] == null:
		print("attack is null!")
	else:
		var my_attack = attack_list[index]
		return my_attack.attack(self, target)

func take_damage(damage: int):
	current_hp -= damage

func heal_damage(health:int):
	current_hp += health
	if current_hp > max_hp:
		current_hp = max_hp

func add_effect(effect):
	var has_this_effect = false
	
	if effect_node.get_child_count() > 0:
		for x in effect_node.get_child_count():
			if effect_node.get_child(x).get_effect_name() == effect.get_effect_name():
				has_this_effect = true
				
	if !has_this_effect:
		effect_node.add_child(effect)

func activate_all_effects():
	if effect_node.get_child_count() > 0:
		for x in effect_node.get_child_count():
			effect_node.get_child(x).activate_effect()

func get_sprite():
	return sprite2d.texture

func gain_exp(exp: int):
	experience += exp
	
	# Add more complex experience system later
	if experience > level && level < level_max:
		experience = 0
		level_up()

func level_up():
	level += 1
	# Consider moving these later
	max_hp += level_hp_bonus
	current_hp += level_hp_bonus
	speed += level_spd_bonus

func transform_monster(trans_mon: PackedScene, index: int):
	print("oh! it's transforming")
	emit_signal("monster_transforms", trans_mon, index)

func check_transformation(index: int):
	if transform_node.get_child_count() > 0:
		for x in transform_node.get_child_count():
			var chosen_option = transform_node.get_child(x)
			if chosen_option.check_can_transform() == true:
				transform_monster(chosen_option.TransMon, index)
	else:
		print("no transformations exist")
