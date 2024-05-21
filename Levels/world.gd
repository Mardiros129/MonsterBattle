extends Node2D


@onready var character = $Character

@onready var removable = $Removable

@onready var enemy_path : Array[String]

@onready var hud = $HUD
@onready var remaining_counter = $HUD/RemainingCounter
@onready var screen_wipe = $HUD/ScreenWipe
@onready var screen_wipe_pos : Vector2
@onready var transitioning = false
@export var transition_speed = 100


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
		
	hud.setup_hud()
	hud.show()
	screen_wipe_pos = screen_wipe.position
	remaining_counter.text = str(MonsterPool.pool_size) + " Monsters Remain"


func _process(delta):
	if transitioning:
		screen_wipe.position.x += delta * transition_speed
	
	if screen_wipe.position.x >= 0:
		transitioning = false
		screen_wipe.hide()
		character.unfreeze()
		screen_wipe.position = screen_wipe_pos
		
		load_enemy_battle()


func transition_to_fight():
	transitioning = true
	screen_wipe.show()
	character.freeze()


func load_enemy_battle():
	# Save world scene
	WorldLoad.world = duplicate()
	WorldLoad.player_position = character.position
	WorldLoad.removable.clear() # reset before adding stuff in
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
		enemy_path = path
		transition_to_fight()
