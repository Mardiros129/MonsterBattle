extends CanvasLayer


@onready var loadout_buttons = $LoadoutButtons
@onready var monster_loadout_0 = $LoadoutButtons/MonsterLoadout0
@onready var monster_loadout_1 = $LoadoutButtons/MonsterLoadout1
@onready var monster_loadout_2 = $LoadoutButtons/MonsterLoadout2
@onready var monster_loadout_3 = $LoadoutButtons/MonsterLoadout3
@onready var swap_text = $Swap
@onready var swapping = false
@onready var swap_index_a
@onready var swap_index_b


func setup_hud():
	for x in loadout_buttons.get_child_count():
		loadout_buttons.get_child(x).clear_monster_loadout()
		
	for x in MonsterParty.party.size():
		var monster_path = MonsterParty.party[x]
		var temp_monster = load(monster_path).instantiate()
		add_child(temp_monster)
		temp_monster.hide()
		loadout_buttons.get_child(x).setup_monster_loadout(temp_monster, x)
		loadout_buttons.get_child(x).disabled = false


func check_swap(index: int):
	if !swapping:
		swapping = true
		swap_text.show()
		swap_index_a = index
	else:
		swapping = false
		swap_text.hide()
		swap_index_b = index
		
		if swap_index_a != swap_index_b:
			MonsterParty.swap_party(swap_index_a, swap_index_b)
			setup_hud()


func _on_monster_loadout_0_pressed():
	check_swap(0)


func _on_monster_loadout_1_pressed():
	check_swap(1)


func _on_monster_loadout_2_pressed():
	check_swap(2)


func _on_monster_loadout_3_pressed():
	check_swap(3)


func _on_update_mon_hud(mon_inst, index):
	loadout_buttons.get_child(index).setup_monster_loadout(mon_inst, index)
	loadout_buttons.get_child(index).disabled = false
