extends Node2D


@export var starter_mon_path: String
@export var support_mon0_path: String
@export var support_mon1_path: String
@export var sideboard_mon_path: String
@export var catch_counter = 0

func _ready():
	create_party_member(starter_mon_path)
	if support_mon0_path != "":
		create_party_member(support_mon0_path)
	if support_mon1_path != "":
		create_party_member(support_mon1_path)
	if sideboard_mon_path != "":
		create_party_member(sideboard_mon_path)
	
	PlayerInventory.catch_counter = catch_counter

func create_party_member(path):
	var mon_inst = load(path).instantiate(false)
	MonsterParty.add_to_party(mon_inst)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			start_game()

func start_game():
	get_tree().change_scene_to_file("res://Levels/world.tscn")

func _on_button_pressed():
	start_game()
