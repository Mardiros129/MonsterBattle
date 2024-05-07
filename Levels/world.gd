extends Node2D

@onready var character = $Character
@onready var canvas_layer = $CanvasLayer
@onready var removable = $Removable


func _ready():
	# If reloading the scene, load the saved nodes
	if !WorldLoad.first_load:
		character.position = WorldLoad.player_position
		if removable.get_child_count() > 0:
			for x in removable.get_child_count():
				var child = removable.get_child(x)
				child.queue_free()
		if WorldLoad.removable.size() > 0:
			for x in WorldLoad.removable.size():
				removable.add_child(WorldLoad.removable[x])
	else:
		WorldLoad.first_load = false
		
	for x in MonsterParty.party.size():
		var temp_monster = MonsterParty.party[x].duplicate()
		add_child(temp_monster)
		temp_monster.hide()
		canvas_layer.get_child(x).icon = temp_monster.get_sprite()
	
	canvas_layer.show()

func load_enemy_battle(enemy_path):
	# Save world scene
	#WorldLoad.world = duplicate()
	WorldLoad.player_position = character.position
	WorldLoad.removable.clear()
	if removable.get_child_count() > 0:
		for x in removable.get_child_count():
			WorldLoad.removable.append(removable.get_child(x).duplicate())
	
	# Load battle scene
	var battle_inst = load("res://Levels/main.tscn").instantiate(false)
	var enemy_inst = load(enemy_path).instantiate(false)
	var enemy_loc = battle_inst.find_child("EnemyMonLocation", false, false)
	enemy_loc.add_child(enemy_inst, false, false)
	
	get_tree().root.add_child(battle_inst, false, 0)
	queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_monster_area_body_entered_return_path(body, path):
	if path != "":
		load_enemy_battle(path)

func _on_robot_start_fight(path):
	load_enemy_battle(path)
