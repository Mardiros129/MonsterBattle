extends Node2D

@onready var party0 = $Party0
@onready var party1 = $Party1
@onready var party2 = $Party2
@onready var party3 = $Party3
@onready var party_button = [party0, party1, party2, party3]
@onready var lose_label = $LoseLabel
@onready var explore_button = $ExploreButton


func _ready():
	if MonsterParty.party.size() == 0:
		lose_label.show()
		explore_button.text = "End"
	
	for x in MonsterParty.party.size():
		var temp_monster = MonsterParty.party[x].duplicate()
		add_child(temp_monster)
		temp_monster.level = MonsterParty.party_level[x]
		temp_monster.monster_transforms.connect(_on_monster_transforms)
		temp_monster.check_transformation(x)
		temp_monster.hide()
		party_button[x].icon = temp_monster.get_sprite()

func go_to_world():
	var inst = load("res://Levels/world.tscn").instantiate()
	#get_tree().root.add_child(WorldLoad.world)
	get_tree().root.add_child(inst)
	queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			go_to_world()

func _on_button_pressed():
	if MonsterParty.party.size() == 0:
		get_tree().quit()
	else:
		go_to_world()

func _on_monster_transforms(trans_mon: PackedScene, index: int):
	var new_mon = trans_mon.instantiate()
	
	var old_mon = MonsterParty.party[index]
	MonsterParty.party[index] = new_mon
	
	var health_bonus = new_mon.max_hp - old_mon.max_hp
	MonsterParty.party_hp[index] += health_bonus
