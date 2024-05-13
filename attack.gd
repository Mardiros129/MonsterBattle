extends Node2D

@export var attack_name = "missing_name"
@export var base_damage = 0
@export var healing = 0
@export var uses = 5
@export var type: TypeList.Type
@export var category: TypeList.DamageCategory
@export var description: String

@onready var user
@onready var target

enum TargetType {NONE, SELF, OPPONENT, ALLY, ALL}
@export var attack_target: TargetType

@export var effect_scene: PackedScene

@onready var user_message
signal combat_message(message)

func attack(new_user, opponent) -> String:
	user = new_user
	
	if attack_target == TargetType.SELF:
		target = user
	elif attack_target == TargetType.OPPONENT:
		target = opponent
	
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
		attack_damage *= user.strength + (user.level * user.level_str_bonus)
		attack_damage /= target.defense + (target.level * target.level_def_bonus)
	elif category == TypeList.DamageCategory.MAGIC:
		attack_damage *= user.intelligence + (user.level * user.level_int_bonus)
		attack_damage /= target.resistance + (target.level * target.level_res_bonus)
	else:
		print("no type category")
	
	# Same-type attack bonus
	if user_type0 == type || user_type1 == type && type != TypeList.Type.NONE:
		attack_damage *= 1.5
	
	# Multiply the damage by the type advantage for both types
	var multiplier0 = TypeList.TypeAdvantageChart[type][target_type0]
	var multiplier1 = TypeList.TypeAdvantageChart[type][target_type1]
	var multiplier_total = multiplier0 * multiplier1
	attack_damage *= multiplier_total
	
	# Round up to the nearest whole number (ensures attacks always do minimum 1 damage)
	attack_damage = snapped(attack_damage, 1.0)
	target.take_damage(attack_damage)
	
	user_message += "\n" + str(attack_damage) + " damage!"
	if multiplier_total > 1:
		user_message += "\n" + "It's super effective!"
	elif multiplier_total < 1:
		user_message += "\n" + "It's not very effective..."

func gain_health():
	user_message += "\n" + str(healing) + " healed!"
	user.heal_damage(healing)

func create_effect():
	var effect = effect_scene.instantiate()
	target.add_effect(effect)
