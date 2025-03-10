extends Node


var party : Array[String]
var party_name : Array[String]
var party_hp : Array[int]
var party_exp : Array[int]
var party_level : Array[int]
var party_moves : Array[Array]


func new_add_to_party(path):
	var monster = load(path).instantiate()
	
	party.append(path)
	party_name.append(monster.my_name)
	party_hp.append(monster.max_hp)
	party_exp.append(0)
	party_level.append(monster.level)
	
	var move_list = []
	for x in monster.find_child("DefaultMoveNode").get_child_count():
		var move_path = monster.find_child("DefaultMoveNode").get_child(x).get_scene_file_path()
		move_list.append(move_path)
	party_moves.append(move_list)


func save_party_member(monster):
	party.append(monster.get_scene_file_path())
	party_name.append(monster.my_name)
	party_hp.append(monster.current_hp)
	party_exp.append(monster.experience)
	party_level.append(monster.level)
	
	var move_list = []
	for x in monster.move_list.size():
		var move_path = monster.move_list[x].get_scene_file_path()
		move_list.append(move_path)
	party_moves.append(move_list)


func clear_all():
	party.clear()
	party_name.clear()
	party_hp.clear()
	party_exp.clear()
	party_level.clear()
	party_moves.clear()


func pop_at(index):
	party.pop_at(index)
	party_name.pop_at(index)
	party_hp.pop_at(index)
	party_exp.pop_at(index)
	party_level.pop_at(index)
	party_moves.pop_at(index)


# See if there's a way to refactor this.
func swap_party(index_a: int, index_b: int):
	var temp_monster = party[index_a]
	party[index_a] = party[index_b]
	party[index_b] = temp_monster
	
	var temp_name =  party_name[index_a]
	party_name[index_a] = party_name[index_b]
	party_name[index_b] = temp_name
	
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
