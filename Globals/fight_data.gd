extends Node


@onready var boss_fight := false
@onready var run_chance = 100.0
@onready var catch_chance = 0.0
@onready var spell_healing = 50
# First item is null so that indexing matches level, e.g. @ level 1 you need 2 exp to level up
@onready var level_exp_requirements = [null, 4, 6, 8, 10, 12, 14, 16, 18, 20]
@onready var enemy_speed : int
