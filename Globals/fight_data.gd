extends Node


@onready var boss_fight := false
@onready var run_chance = 100.0
@onready var catch_chance = 0.0
@onready var potion_healing = 50
# First item is null so that indexing matches level, e.g. @ level 1 you need 2 exp to level up
@onready var level_exp_requirements = [null, 2, 3, 4, 5, 6, 7, 8, 9, 10]
