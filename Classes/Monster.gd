extends Node2D
#class_name Monster


@onready var sprite2d = $Sprite2D
@onready var move_node = $MoveNode
@onready var transform_node = $TransformNode
@onready var status_node = $StatusNode
@onready var animation_player = $AnimationPlayer
@onready var death_timer = $DeathTimer
@onready var card_frame = $CardFrame

@onready var hit_sound = $HitSound
@onready var death_sound = $DeathSound
@onready var heal_sound = $HealSound

@onready var effect_attachment_point = $EffectAttachmentPoint

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
@onready var experience = 0
@onready var exp_req = 2

@onready var move_list: Array

@export var type0: CombatRules.Type
@export var type1: CombatRules.Type

@export var catchable = true
@onready var is_enemy = false

signal monster_transforms(trans_mon, index)


func _ready():
	current_hp = max_hp
	current_speed = speed
	
	card_frame.hide()
	sprite2d.flip_h = false
	
	# Setup moves
	for x in move_node.get_child_count():
		move_list.append(move_node.get_child(x))


func setup_enemy():
	is_enemy = true
	
	sprite2d.flip_h = true
	sprite2d.position.x *= -1
	effect_attachment_point.flip_h = true
	effect_attachment_point.position.x *= -1


func attack(index, target):
	if move_list[index] == null:
		print("move is null!")
	else:
		var my_attack = move_list[index]
		if my_attack.category == CombatRules.DamageCategory.UTILITY:
			animation_player.play("use_ability")
		elif is_enemy:
			animation_player.play("enemy_attack")
		else:
			animation_player.play("player_attack")
		
		return my_attack.attack(self, target)


func take_damage(damage: int):
	animation_player.play("damage")
	hit_sound.play()
	current_hp -= damage


func heal_damage(health:int):
	heal_sound.play()
	current_hp += health
	if current_hp > max_hp:
		current_hp = max_hp


func die():
	animation_player.play("die")
	death_sound.play()
	death_timer.start()


func catch_anim():
	is_enemy = false
	animation_player.play("catch")


func add_status(status):
	var has_this_status = false
	
	if status_node.get_child_count() > 0:
		for x in status_node.get_child_count():
			if status_node.get_child(x).get_status_name() == status.get_status_name():
				has_this_status = true
				
	if !has_this_status:
		status_node.add_child(status)


func activate_all_statuses():
	if status_node.get_child_count() > 0:
		for x in status_node.get_child_count():
			status_node.get_child(x).activate_status()


func display_monster():
	sprite2d.show()


func reset_anim():
	animation_player.play("RESET")
	sprite2d.flip_h = false


func run():
	animation_player.play("run")


func get_sprite():
	return sprite2d.texture


func attach_effect(effect):
	effect_attachment_point.add_child(effect)


func gain_exp(acquired_exp: int):
	experience += acquired_exp
	
	# Exp requirement is a global
	if (experience >= FightData.level_exp_requirements[level]) and (level < level_max):
		experience -= FightData.level_exp_requirements[level]
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


func _on_death_timer_timeout():
	queue_free()
