extends Node2D


@export var catch_counter = 0

func _ready():
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

func _on_animal_starter_pressed():
	create_party_member("res://Monsters/rat.tscn")
	start_game()

func _on_plant_starter_pressed():
	create_party_member("res://Monsters/sprout.tscn")
	start_game()

func _on_undead_starter_pressed():
	create_party_member("res://Monsters/skeleton.tscn")
	start_game()
