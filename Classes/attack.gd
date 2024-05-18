extends Node2D
#class_name Move


signal combat_message(message)
@export var attack_name = "missing_name"
@export var base_damage = 0
@export var healing = 0
@export var uses = 5
@export var type: CombatRules.Type
@export var category: CombatRules.DamageCategory
@export var description: String
@export var attack_target: CombatRules.TargetType

@export var effect: PackedScene
@export var effect_target: CombatRules.TargetType

@onready var user
@onready var target

@export var status_scene: PackedScene

@onready var user_message


func attack(new_user, opponent) -> String:
	user = new_user
	
	if attack_target == CombatRules.TargetType.SELF:
		target = user
	elif attack_target == CombatRules.TargetType.OPPONENT:
		target = opponent
	
	user_message = user.my_name + " used " + attack_name
	
	if base_damage > 0:
		do_damage()
	if healing > 0:
		gain_health()
	if status_scene != null:
		create_status()
	
	if effect != null:
		play_effect_on_target()
	emit_signal("combat_message", user_message)
	return attack_name


func do_damage():
	var user_type0 = user.type0
	var user_type1 = user.type1
	var target_type0 = target.type0
	var target_type1 = target.type1
	var attack_damage = base_damage
	
	# Multiply by damage categories
	if category == CombatRules.DamageCategory.PHYSICAL:
		attack_damage *= user.strength + (user.level * user.level_str_bonus)
		attack_damage /= target.defense + (target.level * target.level_def_bonus)
	elif category == CombatRules.DamageCategory.MAGIC:
		attack_damage *= user.intelligence + (user.level * user.level_int_bonus)
		attack_damage /= target.resistance + (target.level * target.level_res_bonus)
	else:
		print("no type category")
	
	# Same-type attack bonus
	if user_type0 == type || user_type1 == type && type != CombatRules.Type.NONE:
		attack_damage *= 1.5
	
	# Multiply the damage by the type advantage for both types
	var multiplier0 = CombatRules.TypeAdvantageChart[type][target_type0]
	var multiplier1 = CombatRules.TypeAdvantageChart[type][target_type1]
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


func create_status():
	var status = status_scene.instantiate()
	target.add_status(status)


func play_effect_on_target():
	var new_effect = effect.instantiate()
	
	if effect_target == CombatRules.TargetType.SELF:
		user.attach_effect(new_effect)
	elif effect_target == CombatRules.TargetType.OPPONENT:
		target.attach_effect(new_effect)
	else:
		pass # case for all targets later?
	new_effect.play_effect()
