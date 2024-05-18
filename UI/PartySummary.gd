extends Node2D


@onready var party0 = $MemberSummary0
@onready var party1 = $MemberSummary1
@onready var party2 = $MemberSummary2
@onready var party3 = $MemberSummary3

@onready var party_button = [party0, party1, party2, party3]


# Need to refactor this later
func setup_ui():
	for x in party_button.size():
		if MonsterParty.party.size() > x:
			var temp_monster = load(MonsterParty.party[x]).instantiate()
			add_child(temp_monster)
			temp_monster.level = MonsterParty.party_level[x]
			temp_monster.monster_transforms.connect(_on_monster_transforms)
			temp_monster.check_transformation(x)
			temp_monster.hide()
			party_button[x].icon = temp_monster.get_sprite()
			
			party_button[x].find_child("Name").text = temp_monster.name
			party_button[x].find_child("Level").text = "Level " + str(MonsterParty.party_level[x])
			party_button[x].find_child("HPBar").max_value = temp_monster.max_hp
			party_button[x].find_child("HPBar").value = MonsterParty.party_hp[x]
			party_button[x].find_child("ExpBar").max_value = FightData.level_exp_requirements[MonsterParty.party_level[x]]
			party_button[x].find_child("ExpBar").value = MonsterParty.party_exp[x]
		else:
			party_button[x].hide()


func _on_monster_transforms(trans_mon: PackedScene, index: int):
	var new_mon = trans_mon.instantiate()
	
	var old_mon = load(MonsterParty.party[index]).instantiate()
	MonsterParty.party[index] = new_mon.get_scene_file_path()
	
	# Set the transformation's health
	var health_bonus = new_mon.max_hp - old_mon.max_hp
	MonsterParty.party_hp[index] += health_bonus
	
	# Set the transformation's attacks
	var attacks = old_mon.find_child("AttackNode")
	for x in new_mon.find_child("AttackNode").get_children():
		new_mon.find_child("AttackNode").remove_child(x)
	for x in attacks.get_child_count():
		new_mon.find_child("AttackNode").add_child(attacks.get_child(x).duplicate())
