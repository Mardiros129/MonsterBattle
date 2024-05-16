extends Node2D


@onready var character = $Character
@onready var hud = $HUD
@onready var remaining_counter = $HUD/RemainingCounter
@onready var loadout_buttons = $HUD/LoadoutButtons
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
		loadout_buttons.get_child(x).setup_monster_loadout(temp_monster, x)
		loadout_buttons.get_child(x).disabled = false
	
	hud.show()
	remaining_counter.text = str(MonsterPool.pool_size) + " Monsters Remain"


func load_enemy_battle(enemy_path):
	# Save world scene
	WorldLoad.player_position = character.position
	WorldLoad.removable.clear()
	if removable.get_child_count() > 0:
		for x in removable.get_child_count():
			WorldLoad.removable.append(removable.get_child(x).duplicate())
	
	# Load battle scene
	var battle_inst = load("res://Levels/main.tscn").instantiate(false)
	
	var enemy_loc = battle_inst.find_child("EnemyMonLocation", false, false)
	for x in enemy_path.size():
		var enemy_inst = load(enemy_path[x]).instantiate(false)
		enemy_loc.add_child(enemy_inst, false, false)
	
	FightData.catch_chance = 0.0 # Can't catch at full HP; could change later
	
	get_tree().root.add_child(battle_inst)
	queue_free()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


# Consider renaming to something like "fight triggered"
func _on_monster_area_body_entered_return_path(_body, path):
	if path[0] != "":
		load_enemy_battle(path)
