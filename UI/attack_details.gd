extends Control

@onready var my_type: int
@onready var my_damage: int
@onready var my_healing: int
@onready var my_description: String

@onready var attack_type_label = $AttackType
@onready var attack_damage_label = $AttackDamage
@onready var attack_description_label = $AttackDescription

func set_attack_details(attack):
	my_type = attack.type
	my_damage = attack.base_damage
	my_healing = attack.healing
	my_description = attack.description
	
	attack_type_label.text = TypeList.TypeName[my_type] + " type"
	
	attack_damage_label.text = ""
	if my_damage > 0:
		attack_damage_label.text = str(my_damage) + " damage"
	if my_damage > 0 && my_healing > 0:
		attack_damage_label.text += ", "
	if my_healing > 0:
		attack_damage_label.text += str(my_healing) + " healing"
	attack_description_label.text = my_description
