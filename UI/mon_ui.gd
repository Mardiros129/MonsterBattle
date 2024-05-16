extends Control


@onready var my_name = $MyName
@onready var level_types = $LevelTypes
@onready var hp = $HP
@onready var speed = $Speed
@onready var hp_bar = $HPBar


func set_mon_ui(monster):
	my_name.text = monster.my_name
	level_types.text = "Level " + str(monster.level) + " "
	set_mon_hp_ui(monster)
	level_types.text += CombatRules.TypeName[monster.type0]
	if CombatRules.TypeName[monster.type1] != "":
		level_types.text += "/" + CombatRules.TypeName[monster.type1]
	update_mon_speed_ui(monster)


func set_mon_hp_ui(monster):
	var current_hp_text = monster.current_hp
	if current_hp_text < 0:
		current_hp_text = 0
	hp.text = str(current_hp_text) + "/" + str(monster.max_hp)
	
	hp_bar.max_value = monster.max_hp
	hp_bar.value = monster.current_hp


func update_mon_speed_ui(monster):
	speed.text = "Speed " + str(monster.current_speed)
