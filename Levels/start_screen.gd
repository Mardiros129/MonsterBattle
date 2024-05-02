extends Node2D


@export var starter_mon_path: String
@export var support_mon0_path: String
@export var support_mon1_path: String

func _ready():
	create_party_member(starter_mon_path)
	if support_mon0_path != "":
		create_party_member(support_mon0_path)
	if support_mon1_path != "":
		create_party_member(support_mon1_path)

func create_party_member(path):
	var mon_inst = load(path).instantiate(false)
	MonsterParty.add_to_party(mon_inst)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Levels/world.tscn")
