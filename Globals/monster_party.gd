extends Node


var party : Array[String]
var party_hp : Array[int]
var party_exp : Array[int]
var party_level : Array[int]
var party_moves : Array


func new_add_to_party(path):
	var monster = load(path).instantiate()
	
	party.append(path)
	party_hp.append(monster.max_hp)
	party_exp.append(0)
	party_level.append(monster.level)
	party_moves.append("placeholder") # placeholder


func add_to_party(monster):
	party.append(monster.get_scene_file_path())
	party_hp.append(monster.current_hp)
	party_exp.append(monster.experience)
	party_level.append(monster.level)
	party_moves.append("placeholder") # placeholder


func clear_all():
	party.clear()
	party_hp.clear()
	party_exp.clear()
	party_level.clear()
	party_moves.clear()


func swap_party(index_a: int, index_b: int):
	var temp_monster = party[index_a]
	party[index_a] = party[index_b]
	party[index_b] = temp_monster
	
	var temp_hp = party_hp[index_a]
	party_hp[index_a] = party_hp[index_b]
	party_hp[index_b] = temp_hp
	
	var temp_exp = party_exp[index_a]
	party_exp[index_a] = party_exp[index_b]
	party_exp[index_b] = temp_exp
	
	var temp_level = party_level[index_a]
	party_level[index_a] = party_level[index_b]
	party_level[index_b] = temp_level
	
	var temp_moves = party_moves[index_a]
	party_moves[index_a] = party_moves[index_b]
	party_moves[index_b] = temp_moves
