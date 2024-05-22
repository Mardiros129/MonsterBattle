extends Node

enum Type {NONE, ANIMAL, PLANT, UNDEAD, PIXIE, MECH, ELEMENT, CORRUPT, MYTHIC, DEMON, ANGEL}
@onready var TypeName = ["", "animal", "plant", "undead", "pixie", "mech", "element", "corrupt", "mythic","demon", "angel"]

@onready var TypeColor = [ 
	Color.WHITE, # none
	Color.SANDY_BROWN, # animal
	Color.WEB_GREEN, # plant
	Color.SLATE_GRAY, # undead
	Color.HOT_PINK, # pixie
	Color.ROSY_BROWN, # mech
	Color.ROYAL_BLUE, # element
	Color.MEDIUM_PURPLE, # corrupt
	Color.GOLD, # mythic
	Color.DARK_RED, # demon
	Color.ANTIQUE_WHITE, # angel
	]

@onready var TypeAdvantageChart: Array[Array]
@onready var NoneTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@onready var AnimalTypeAdvantage = [1.0, 1.0, 2.0, 0.5, 2.0, 0.5, 1.0, 0.5, 0.5, 1.0, 1.0]
@onready var PlantTypeAdvantage = [1.0, 0.5, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0]
@onready var UndeadTypeAdvantage = [1.0, 2.0, 0.5, 0.5, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0]
@onready var PixieTypeAdvantage = [1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0, 1.0]
@onready var MechTypeAdvantage = [1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 0.5, 1.0, 1.0, 1.0, 1.0]
@onready var ElementTypeAdvantage = [1.0, 1.0, 2.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@onready var CorruptTypeAdvantage = [1.0, 2.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0]
@onready var MythicTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0]
@onready var DemonTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0]
@onready var AngelTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0]

enum DamageCategory { UTILITY, PHYSICAL, MAGIC, STATUS }
@onready var DamageCategoryName = ["utility", "physical", "magic"]

enum TargetType { 
	NONE,
	SELF,
	OPPONENT,
	ALL_ALLIES,
	ALL_OPPONENTS,
	ALLY_SUPPORT,
	OPPONENT_SUPPORT,
	ALLY_BACKLINE,
	OPPONENT_BACKLINE,
	BOTH_POINTS,
	BOTH_BACKLINES,
	ALL
	}


func _ready():
	TypeAdvantageChart.append(NoneTypeAdvantage)
	TypeAdvantageChart.append(AnimalTypeAdvantage)
	TypeAdvantageChart.append(PlantTypeAdvantage)
	TypeAdvantageChart.append(UndeadTypeAdvantage)
	TypeAdvantageChart.append(PixieTypeAdvantage)
	TypeAdvantageChart.append(MechTypeAdvantage)
	TypeAdvantageChart.append(ElementTypeAdvantage)
	TypeAdvantageChart.append(CorruptTypeAdvantage)
	TypeAdvantageChart.append(MythicTypeAdvantage)
	TypeAdvantageChart.append(DemonTypeAdvantage)
	TypeAdvantageChart.append(AngelTypeAdvantage)
