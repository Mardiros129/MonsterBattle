extends Button


@onready var level_label = $Level
@onready var total_exp_label = $Exp
@onready var health_bar = $HealthBar
@onready var exp_bar = $ExpBar


func setup_monster_loadout(monster, index):
	var level = MonsterParty.party_level[index]
	var exp = MonsterParty.party_exp[index]
	var hp = MonsterParty.party_hp[index]
	
	icon =  monster.get_sprite()
	level_label.text = "Lv " + str(level)
	total_exp_label.text = str(exp) + "/" + str(FightData.level_exp_requirements[level])
	exp_bar.max_value = FightData.level_exp_requirements[level]
	exp_bar.value = exp
	
	if MonsterParty.party_hp.size() > 0:
		health_bar.max_value = monster.max_hp
		health_bar.value = hp
	
	level_label.show()
	exp_bar.show()
	health_bar.show()


func clear_monster_loadout():
	level_label.hide()
	exp_bar.hide()
	health_bar.hide()
	disabled = true
	icon = null
