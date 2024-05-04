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
