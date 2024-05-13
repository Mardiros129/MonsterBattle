extends Control

@onready var my_name = $MyName
@onready var level = $Level
@onready var hp = $HP
@onready var types = $Types
@onready var speed = $Speed
@onready var hp_bar = $HPBar


func set_mon_ui(monster):
	my_name.text = monster.my_name
	level.text = "Level " + str(monster.level)
	set_mon_hp_ui(monster)
	types.text = TypeList.TypeName[monster.type0]
	if TypeList.TypeName[monster.type1] != "":
		types.text += "/" + TypeList.TypeName[monster.type1]
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
