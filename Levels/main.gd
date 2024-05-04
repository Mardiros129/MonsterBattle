extends Node2D


@onready var player_turn = true
@onready var resolve_turn_timer = $ResolveTurnTimer
@onready var player_mon_loc = $PlayerMonLocation
@onready var enemy_mon_loc = $EnemyMonLocation

@export var player_monster0: Node2D
@export var player_monster1: Node2D
@export var player_monster2: Node2D
@export var player_monster3: Node2D
# Maintain the order for the whole game
@onready var mon_team: Array

@onready var player_mon
@onready var support_mon0
@onready var support_mon1
@onready var sideboard_mon
@export var enemy_mon: Node2D

@onready var command_queue: Array
@export var command_delay = 0.3

@export var catch_chance = 0.1
@onready var captured = false

@onready var ui = $UI
@onready var end_button = $UI/EndButton


func _ready():
	# Refactor later
	if MonsterParty.party.size() > 0:
		player_monster0 = MonsterParty.party[0]
		player_mon_loc.add_child(player_monster0)
		mon_team.append(player_monster0)
		player_mon = mon_team[0]
		
	if MonsterParty.party.size() > 1:
		player_monster1 = MonsterParty.party[1]
		player_mon_loc.add_child(player_monster1)
		mon_team.append(player_monster1)
		support_mon0 = mon_team[1]
		support_mon0.hide()
		
	if MonsterParty.party.size() > 2:
		player_monster2 = MonsterParty.party[2]
		player_mon_loc.add_child(player_monster2)
		mon_team.append(player_monster2)
		support_mon1 = mon_team[2]
		support_mon1.hide()
		
	if MonsterParty.party.size() > 3:
		player_monster3 = MonsterParty.party[3]
		player_mon_loc.add_child(player_monster3)
		mon_team.append(player_monster3)
		sideboard_mon = mon_team[3]
		sideboard_mon.hide()
	
	enemy_mon = enemy_mon_loc.get_child(0, false)
	
	# Signals
	for x in mon_team.size():
		mon_team[x].damage_enemy.connect(_player_damages_enemy)
		mon_team[x].combat_message.connect(_on_combat_message_received)
	enemy_mon.combat_message.connect(_on_combat_message_received)
	
	ui.set_moves(player_mon)
	ui.set_button_icons(mon_team)
	ui.set_catch_labels(PlayerInventory.catch_counter, catch_chance)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func start_turn():
	ui.enable_ui(PlayerInventory.catch_counter)
	player_turn = true

func end_turn():
	player_turn = false
	ui.disable_ui()
	enemy_chooses_attack()
	
	# Go through everything in the queue one-by-one.
	var combat_finished = false
	
	for x in command_queue.size():
		var command = command_queue.pop_front()
		if command.get_user() == player_mon:
			player_mon.attack(command.attack, enemy_mon.type1, enemy_mon.type2)
		elif command.user == enemy_mon:
			var damage = enemy_mon.attack(command.attack, player_mon.type1, player_mon.type2)
			player_mon.take_damage(damage)
		
		if enemy_mon.current_hp <= 0:
			ui.update_log("Enemy " + enemy_mon.my_name + " died!")
			await get_tree().create_timer(command_delay).timeout
			
			ui.update_log("You won!")
			await get_tree().create_timer(command_delay).timeout
			
			enemy_mon.queue_free()
			combat_finished = true
		
		elif player_mon.current_hp <= 0:
			player_mon_dies()
			if player_mon == null:
				ui.update_log("You lose!")
				await get_tree().create_timer(command_delay).timeout
				combat_finished = true
		
		await get_tree().create_timer(command_delay).timeout
		
		if combat_finished:
			break
		
	if combat_finished:
		end_combat()
	else:
		command_queue.clear()
		start_turn()

func end_combat():
	ui.disable_ui()
	end_button.show()

func switch(button_index):
	player_mon.visible = false
	ui.swap_buttons(player_mon, button_index)
	
	# Swap the roles. Don't swap the order in the party.
	var temp = player_mon
	if button_index == 0:
		player_mon = support_mon0
		support_mon0 = temp
	elif button_index == 1:
		player_mon = support_mon1
		support_mon1 = temp
	
	player_mon.visible = true
	ui.set_moves(player_mon)
	ui.update_log(player_mon.my_name + " swapped in!")
	await get_tree().create_timer(command_delay).timeout
	end_turn()

func player_mon_dies():
	ui.update_log(player_mon.my_name + " died!")
	await get_tree().create_timer(command_delay).timeout
	
	player_mon.queue_free()
	if support_mon0 != null:
		player_mon = support_mon0
		support_mon0 = support_mon1
		support_mon1 = sideboard_mon
		player_mon.visible = true
		ui.set_moves(player_mon)
		ui.pop_button()

# To do, implement some AI behavior
func enemy_chooses_attack():
	var rng = RandomNumberGenerator.new()
	var result = rng.randi_range(0, enemy_mon.attack_list.size()-1)
	new_command(result, enemy_mon, player_mon)

func new_command(attack, user, target):
	var command = preload("res://command.gd").new()
	command.user = user
	command.target = target
	command.attack = attack
	command.speed = user.speed
	
	# Adds the command to the queue based on its speed. Highest number is first.
	if command_queue.size() == 0:
		command_queue.append(command)
	else:
		for x in command_queue.size():
			if command_queue[x].speed < command.speed:
				command_queue.insert(x, command)
			elif x == command_queue.size()-1:
				command_queue.append(command)

func _on_catch_button_pressed():
	PlayerInventory.catch_counter -= 1
	ui.update_catch_count(PlayerInventory.catch_counter)
	
	var rng = RandomNumberGenerator.new()
	var result = rng.randf()
	if result <= catch_chance:
		ui.update_log("Catch success!")
		await get_tree().create_timer(command_delay).timeout
		captured = true
		enemy_mon.hide()
		end_combat()
	else:
		ui.update_log("Catch failed...")
		await get_tree().create_timer(command_delay).timeout
		end_turn()

func _player_damages_enemy(dmg):
	enemy_mon.take_damage(dmg)

func _on_switch_button_0_pressed():
	switch(0)

func _on_switch_button_1_pressed():
	switch(1)

func _on_combat_message_received(message: String):
	ui.update_log(message)

func _on_attack_button_pressed():
	new_command(ui.get_selected_move(), player_mon, enemy_mon)
	end_turn()

func _on_end_button_pressed():
	# Setup party, exclide slain allies, include captured enemy
	MonsterParty.party.clear()
	for x in mon_team.size():
		if mon_team[x] != null:
			MonsterParty.add_to_party(mon_team[x].duplicate())
	if captured:
		MonsterParty.add_to_party(enemy_mon.duplicate())
	
	# Load next scene
	var inst = load("res://Levels/end_screen.tscn").instantiate()
	get_tree().root.add_child(inst, false, 0)
	queue_free()

func _on_run_button_pressed():
	ui.update_log("You got away safely!")
	end_combat()

func _on_reset_pressed():
		get_tree().reload_current_scene()
