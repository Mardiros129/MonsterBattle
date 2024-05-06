extends Node2D

@export var attack_name = "missing_name"
@export var base_damage = 0
@export var healing = 0
@export var uses = 5
@export var type: TypeList.Type
@export var category: TypeList.DamageCategory

@onready var user
@onready var target

@export var effect_scene: PackedScene

@onready var user_message
signal combat_message(message)

func attack(new_user, new_target) -> String:
	user = new_user
	target = new_target
	user_message = user.my_name + " used " + attack_name
	
	if base_damage > 0:
		do_damage()
	if healing > 0:
		gain_health()
	if effect_scene != null:
		create_effect()
	
	emit_signal("combat_message", user_message)
	return attack_name

func do_damage():
	var user_type0 = user.type0
	var user_type1 = user.type1
	var target_type0 = target.type0
	var target_type1 = target.type1
	var attack_damage = base_damage
	
	# Multiply by damage categories
	if category == TypeList.DamageCategory.PHYSICAL:
		attack_damage *= user.strength
		attack_damage /= target.defense
	elif category == TypeList.DamageCategory.MAGIC:
		attack_damage *= user.intelligence
		attack_damage /= target.resistance
	else:
		print("no type category")
	
	# Same-type attack bonus
	if user_type0 == type || user_type1 == type && type != TypeList.Type.NONE:
		attack_damage *= 1.5
	
	# Multiply the damage by the type advantage for both types
	var multiplier0 = TypeList.TypeAdvantageChart[type][target_type0]
	var multiplier1 = TypeList.TypeAdvantageChart[type][target_type1]
	attack_damage *= multiplier0
	attack_damage *= multiplier1
	# Round up to the nearest whole number (ensures attacks always do minimum 1 damage)
	attack_damage = snapped(attack_damage, 1.0)
	
	user_message += "\n" + str(attack_damage) + " damage!"
	target.take_damage(attack_damage)

func gain_health():
	user_message += "\n" + str(healing) + " healed!"
	user.heal_damage(healing)

func create_effect():
	var effect = effect_scene.instantiate()
	target.add_effect(effect)
