extends Node2D
class_name Move


signal combat_message(message)
@export var move_name = "missing_name"
@export var base_damage = 0
@export var healing = 0
#@export var uses = 5
@export var type : CombatRules.Type
@export var category : CombatRules.DamageCategory
@export var description : String
@export var attack_target : CombatRules.TargetType
@export var healing_target : CombatRules.TargetType

@export var effect : PackedScene
@export var effect_target : CombatRules.TargetType

@onready var user
@onready var ally_team
@onready var opponent_team

@onready var target : Array
@onready var group_to_heal : Array

@export var status_scene : PackedScene

@onready var user_message


func attack(new_user, new_ally_team, new_opponent_team) -> String:
	user = new_user
	ally_team = new_ally_team
	opponent_team = new_opponent_team
	
	if attack_target == CombatRules.TargetType.SELF:
		target.append(user)
	elif attack_target == CombatRules.TargetType.OPPONENT:
		target.append(opponent_team[0])
	
	user_message = user.my_name + " used " + move_name
	
	if base_damage > 0:
		do_damage()
	if healing > 0:
		gain_health()
	if status_scene != null:
		create_status()
	
	if effect != null:
		play_effect_on_target()
	emit_signal("combat_message", user_message)
	return move_name


func do_damage():
	var user_type0 = user.type0
	var user_type1 = user.type1
	var target_type0 = target[0].type0
	var target_type1 = target[0].type1
	var attack_damage = base_damage
	
	# Multiply by damage categories
	if category == CombatRules.DamageCategory.PHYSICAL:
		attack_damage *= user.strength + (user.level * user.level_str_bonus)
		attack_damage /= target[0].defense + (target[0].level * target[0].level_def_bonus)
	elif category == CombatRules.DamageCategory.MAGIC:
		attack_damage *= user.intelligence + (user.level * user.level_int_bonus)
		attack_damage /= target[0].resistance + (target[0].level * target[0].level_res_bonus)
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
	target[0].take_damage(attack_damage)
	
	user_message += "\n" + str(attack_damage) + " damage!"
	if multiplier_total > 1:
		user_message += "\n" + "It's super effective!"
	elif multiplier_total < 1:
		user_message += "\n" + "It's not very effective..."


func gain_health():
	match healing_target:
		CombatRules.TargetType.SELF:
			user.heal_damage(healing)
		CombatRules.TargetType.ALL_ALLIES:
			for x in ally_team.size():
				ally_team[x].heal_damage(healing)
	user_message += "\n" + str(healing) + " healed!"


func create_status():
	var status = status_scene.instantiate()
	target[0].add_status(status)


func play_effect_on_target():
	var new_effect = effect.instantiate()
	
	if effect_target == CombatRules.TargetType.SELF:
		user.attach_effect(new_effect)
	elif effect_target == CombatRules.TargetType.OPPONENT:
		target[0].attach_effect(new_effect)
	else:
		pass # case for all targets later?
	new_effect.play_effect()
