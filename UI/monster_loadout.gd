extends Button


@onready var level = $Level
@onready var exp = $Exp

func setup_monster_loadout(monster):
	icon =  monster.get_sprite()
	level.text = "Lv " + str(monster.level)
	exp.text = str(monster.experience) + "/" + str(monster.level + 1)
	level.show()
	exp.show()
