extends Node2D

@export var max_hp = 1
@onready var current_hp
@export var my_name = "null_name"
@export var speed = 0
@export var level = 1

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
	
	# Setup attacks
	for x in attack_node.get_child_count():
		attack_list.append(attack_node.get_child(x))

func attack(index, target):
	if attack_list[index] == null:
		print("attack is null!")
	else:
		var my_attack = attack_list[index]
		my_attack.attack(self, target)

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
