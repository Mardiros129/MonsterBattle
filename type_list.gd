extends Node

enum Type {NONE, ANIMAL, PLANT, UNDEAD, PIXIE, MECH, DEMON, ANGEL}
@onready var TypeName = ["", "animal", "plant", "undead", "pixie", "mech", "demon", "angel"]

@onready var TypeAdvantageChart: Array[Array]
@onready var NoneTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
@onready var AnimalTypeAdvantage = [1.0, 1.0, 2.0, 0.5, 1.0, 0.5, 1.0, 1.0]
@onready var PlantTypeAdvantage = [1.0, 0.5, 1.0, 2.0, 1.0, 0.5, 1.0, 1.0]
@onready var UndeadTypeAdvantage = [1.0, 2.0, 1.0, 0.5, 0.5, 1.0, 1.0, 1.0]
@onready var PixieTypeAdvantage = [1.0, 2.0, 0.5, 2.0, 1.0, 2.0, 1.0, 1.0]
@onready var MechTypeAdvantage = [1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0]
@onready var DemonTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0]
@onready var AngelTypeAdvantage = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0]

func _ready():
	TypeAdvantageChart.append(NoneTypeAdvantage)
	TypeAdvantageChart.append(AnimalTypeAdvantage)
	TypeAdvantageChart.append(PlantTypeAdvantage)
	TypeAdvantageChart.append(UndeadTypeAdvantage)
	TypeAdvantageChart.append(PixieTypeAdvantage)
	TypeAdvantageChart.append(MechTypeAdvantage)
	TypeAdvantageChart.append(DemonTypeAdvantage)
	TypeAdvantageChart.append(AngelTypeAdvantage)
