extends Node2D

@onready var party0 = $Party0
@onready var party1 = $Party1
@onready var party2 = $Party2
@onready var party3 = $Party3
@onready var party_button = [party0, party1, party2, party3]


func _ready():
	for x in MonsterParty.party.size():
		var monster = MonsterParty.party[x].duplicate()
		add_child(monster)
		monster.hide()
		party_button[x].icon = monster.get_sprite()

func go_to_world():
	var inst = load("res://Levels/world.tscn").instantiate(false)
	get_tree().root.add_child(inst, false, 0)
	queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			go_to_world()

func _on_button_pressed():
	go_to_world()
