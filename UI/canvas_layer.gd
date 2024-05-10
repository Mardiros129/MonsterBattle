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
			var temp_position = loadout_buttons.get_child(swap_index_a).position
			loadout_buttons.get_child(swap_index_a).position = loadout_buttons.get_child(swap_index_b).position
			loadout_buttons.get_child(swap_index_b).position = temp_position
			
			MonsterParty.swap_party(swap_index_a, swap_index_b)

func _on_monster_loadout_0_pressed():
	check_swap(0)

func _on_monster_loadout_1_pressed():
	check_swap(1)

func _on_monster_loadout_2_pressed():
	check_swap(2)

func _on_monster_loadout_3_pressed():
	check_swap(3)
