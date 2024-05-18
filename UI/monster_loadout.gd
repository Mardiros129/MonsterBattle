extends Button


@onready var level = $Level
@onready var total_exp = $Exp
@onready var health_bar = $HealthBar

func setup_monster_loadout(monster, index):
	icon =  monster.get_sprite()
	level.text = "Lv " + str(monster.level)
	total_exp.text = str(monster.experience) + "/" + str(monster.level + 1)
	
	if MonsterParty.party_hp.size() > 0:
		health_bar.max_value = monster.max_hp
		health_bar.value = MonsterParty.party_hp[index]
	
	level.show()
	total_exp.show()
	health_bar.show()


func clear_monster_loadout():
	level.hide()
	total_exp.hide()
	health_bar.hide()
	disabled = true
	icon = null
