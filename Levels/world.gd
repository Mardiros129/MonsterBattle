extends Node2D


@export var starter_mon_path: String

func _ready():
	var starter_mon_inst = load(starter_mon_path).instantiate(false)
	MonsterParty.add_to_party(starter_mon_inst)

func load_enemy_battle(enemy_path):
	var battle_inst = load("res://Levels/main.tscn").instantiate(false)
	var enemy_inst = load(enemy_path).instantiate(false)
	var enemy_loc = battle_inst.find_child("EnemyMonLocation", false, false)
	enemy_loc.add_child(enemy_inst, false, false)
	
	get_tree().root.add_child(battle_inst, false, 0)
	queue_free()

func _on_onion_button_pressed():
	load_enemy_battle("res://Monsters/onion.tscn")

func _on_fireball_button_pressed():
	load_enemy_battle("res://Monsters/fireball.tscn")

func _on_skeleton_button_pressed():
	load_enemy_battle("res://Monsters/skeleton.tscn")
