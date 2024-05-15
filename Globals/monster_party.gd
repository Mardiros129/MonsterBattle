extends Node

var party: Array
var party_hp: Array[int]
var party_level: Array[int]

func new_add_to_party(monster):
	party.append(monster)

func add_to_party(monster, current_hp, level):
	party.append(monster)
	party_hp.append(current_hp)
	party_level.append(level)

func clear_all():
	party.clear()
	party_hp.clear()
	party_level.clear()

func swap_party(index_a: int, index_b: int):
	var temp_monster = party[index_a]
	party[index_a] = party[index_b]
	party[index_b] = temp_monster
	
	var temp_hp = party_hp[index_a]
	party_hp[index_a] = party_hp[index_b]
	party_hp[index_b] = temp_hp
	
	var temp_level = party_level[index_a]
	party_level[index_a] = party_level[index_b]
	party_level[index_b] = temp_level
