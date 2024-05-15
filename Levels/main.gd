extends Node2D


@onready var player_turn = true
@onready var resolve_turn_timer = $ResolveTurnTimer
@onready var player_mon_loc = $PlayerMonLocation
@onready var enemy_mon_loc = $EnemyMonLocation
@onready var run_audio = $RunAudio


@onready var mon_start_lineup: Array # Maintain the original order for the whole game
@onready var player_mon: Array # Change the order by their combat role

@onready var enemy_mon_start_lineup: Array
@onready var enemy_mon
@onready var enemy_support_mon0
@onready var enemy_support_mon1

@onready var command_queue: Array
@export var command_delay = 0.4
@onready var bonus_turn = false # Currently only works for player, need to update later to include enemy

@onready var ui = $UI
@onready var end_button = $UI/EndButton
@onready var click_sound = $UI/ClickSound


func _ready():
	# Setup player party
	mon_start_lineup = MonsterParty.party.duplicate()
	
	for x in MonsterParty.party.size():
		player_mon.append(MonsterParty.party[x])
	
	for x in mon_start_lineup.size():
		player_mon_loc.add_child(mon_start_lineup[x])
		mon_start_lineup[x].hide()
		if MonsterParty.party_hp.size() > 0:
			mon_start_lineup[x].current_hp = MonsterParty.party_hp[x]
		if MonsterParty.party_level.size() > 0:
			mon_start_lineup[x].level = MonsterParty.party_level[x]
	
	player_mon[0].show()
	player_mon[0].reset_anim()
	
	# Setup enemy party
	enemy_mon = enemy_mon_loc.get_child(0)
	enemy_mon_start_lineup.append(enemy_mon)
	
	if enemy_mon_loc.get_child_count() > 1:
		enemy_support_mon0 = enemy_mon_loc.get_child(1)
		enemy_mon_start_lineup.append(enemy_support_mon0)
		enemy_support_mon0.hide()
	if enemy_mon_loc.get_child_count() > 2:
		enemy_support_mon1 = enemy_mon_loc.get_child(2)
		enemy_mon_start_lineup.append(enemy_support_mon1)
		enemy_support_mon1.hide()
	
	for x in enemy_mon_start_lineup.size():
		enemy_mon_start_lineup[x].setup_enemy()
	
	# Setup signals
	var all_monsters = mon_start_lineup + enemy_mon_start_lineup
	for x in all_monsters.size():
		var chosen_mon_attacks = all_monsters[x].find_child("AttackNode")
		for y in chosen_mon_attacks.get_child_count():
			chosen_mon_attacks.get_child(y).combat_message.connect(_on_combat_message_received)
	
	# Setup UI
	ui.set_button_icons(mon_start_lineup)
	ui.set_catch_labels(PlayerInventory.catch_counter, FightData.catch_chance)
	ui.set_player_mon_ui(player_mon[0])
	ui.set_enemy_mon_ui(enemy_mon)
	start_turn()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


func start_turn():
	FightData.catch_chance = 1.0 - float(enemy_mon.current_hp) / float(enemy_mon.max_hp)
	ui.enable_ui()
	ui.update_catch_chance(FightData.catch_chance)
	ui.player_mon_ui.update_mon_speed_ui(player_mon[0])
	ui.enemy_mon_ui.update_mon_speed_ui(enemy_mon)
	if !enemy_mon.catchable:
		ui.not_catchable_button()
	player_turn = true


func end_turn():
	player_turn = false
	var combat_finished = false
	ui.disable_ui()
	enemy_chooses_attack()
	
	# Eventually these should be given their own commands
	player_mon[0].activate_all_effects()
	enemy_mon.activate_all_effects()
	
	# Go through everything in the queue one-by-one.
	for x in command_queue.size():
		var command = command_queue.pop_front()
		if command.get_user() == player_mon[0]:
			player_mon[0].attack(command.attack, enemy_mon)
		elif command.get_user() == enemy_mon:
			var attack_name = enemy_mon.attack(command.attack, player_mon[0])
			ui.populate_enemy_attacks(attack_name)
		
		ui.change_player_hp(player_mon[0])
		ui.change_enemy_hp(enemy_mon)
		
		if enemy_mon.current_hp <= 0:
			enemy_mon_dies()
			
			# Check if the game ends
			if enemy_support_mon0 == null:
				ui.update_log("You won!")
				await get_tree().create_timer(command_delay).timeout
				
				player_mon[0].gain_exp(1)
				MonsterPool.pool_size -= 1
				combat_finished = true
		
		elif player_mon[0].current_hp <= 0:
			player_mon_dies()
			
			if player_mon[0].current_hp <= 0 and player_mon.size() == 1:
				combat_finished = true
				ui.update_log("You lose!")
				await get_tree().create_timer(command_delay).timeout
		
		await get_tree().create_timer(command_delay).timeout
		
		if combat_finished:
			break
		
	if combat_finished:
		command_queue.clear()
		end_combat()
	else:
		command_queue.clear()
		start_turn()


func end_combat():
	ui.disable_ui()
	end_button.show()


func switch(button_index):
	player_mon[0].hide()
	ui.swap_buttons(player_mon[0], button_index)
	
	# Swap the roles. Don't swap the order in the party.
	var temp = player_mon[0]
	if button_index == 0:
		player_mon[0] = player_mon[1]
		player_mon[1] = temp
	elif button_index == 1:
		player_mon[0] = player_mon[2]
		player_mon[2] = temp
	
	player_mon[0].show()
	ui.set_player_mon_ui(player_mon[0])
	ui.update_log(player_mon[0].my_name + " swapped in!")
	await get_tree().create_timer(command_delay).timeout
	
	if player_mon[0].current_speed <= enemy_mon.current_speed:
		end_turn()
	else:
		ui.disable_switch_buttons()
		bonus_turn = true


func player_mon_dies():
	player_mon[0].die()
	ui.update_log(player_mon[0].my_name + " died!")
	await get_tree().create_timer(command_delay).timeout

	if player_mon[1] != null:
		player_mon.pop_front()
		player_mon[0].show()
		ui.set_player_mon_ui(player_mon[0])
		ui.pop_button()


func enemy_mon_dies():
	enemy_mon.die()
	ui.update_log("Enemy " + enemy_mon.my_name + " died!")
	await get_tree().create_timer(command_delay).timeout

	if enemy_support_mon0 != null:
		replace_enemy()


func replace_enemy():
	enemy_mon.hide()
	enemy_mon = enemy_support_mon0
	enemy_support_mon0 = enemy_support_mon1
	enemy_mon.show()
	ui.set_enemy_mon_ui(enemy_mon)


# To do, implement some AI behavior
func enemy_chooses_attack():
	var result = randi_range(0, enemy_mon.attack_list.size() - 1)
	new_command(result, enemy_mon, player_mon[0])


func new_command(attack, user, target):
	var command = preload("res://command.gd").new()
	command.user = user
	command.target = target
	command.attack = attack
	if !bonus_turn:
		command.speed = user.current_speed
	elif user == player_mon[0]:
		# Always go last if it's a bonus turn (regular speed will never be less than 0)
		command.speed = -1
		bonus_turn = false
	
	# Adds the command to the queue based on its speed. Highest number is first.
	if command_queue.size() == 0:
		command_queue.append(command)
	else:
		for x in command_queue.size():
			if command_queue[x].speed < command.speed:
				command_queue.insert(x, command)
			elif x == command_queue.size()-1:
				command_queue.append(command)


func add_monster_to_party(monster):
	player_mon_loc.add_child(monster)
	monster.reset_anim()
	monster.hide()
	player_mon.append(monster)
	mon_start_lineup.append(monster)
	ui.set_button_icons(player_mon)


func _on_catch_button_pressed():
	PlayerInventory.catch_counter -= 1
	ui.update_catch_count(PlayerInventory.catch_counter)
	
	var result = randf()
	if result <= FightData.catch_chance:
		enemy_mon.catch()
		ui.update_log("Catch successful!")
		#await get_tree().create_timer(command_delay).timeout
		await get_tree().create_timer(1.0).timeout
		MonsterPool.pool_size -= 1
		
		# Add to party
		if player_mon.size() < 4:
			enemy_mon_loc.remove_child(enemy_mon)
			add_monster_to_party(enemy_mon)
		else:
			# TODO: send to box
			pass
		
		if enemy_support_mon0 != null:
			replace_enemy()
			start_turn()
		else:
			end_combat()
	
	else:
		ui.update_log("Catch failed...")
		await get_tree().create_timer(command_delay).timeout
		end_turn()


func _player_damages_enemy(dmg):
	enemy_mon.take_damage(dmg)


func _on_switch_button_0_pressed():
	click_sound.play()
	switch(0)


func _on_switch_button_1_pressed():
	click_sound.play()
	switch(1)


func _on_combat_message_received(message: String):
	ui.update_log(message)


func _on_attack_button_pressed():
	click_sound.play()
	new_command(ui.get_selected_move(), player_mon[0], enemy_mon)
	end_turn()


func _on_end_button_pressed():
	click_sound.play()
 	# Setup party, exclude slain allies, include captured enemy
	MonsterParty.clear_all()
	for x in mon_start_lineup.size():
		var current_mon = mon_start_lineup[x]
		if current_mon != null:
			MonsterParty.add_to_party(current_mon.duplicate(), current_mon.current_hp, current_mon.level)
	
	# Load next scene
	var inst = load("res://Levels/end_screen.tscn").instantiate()
	get_tree().root.add_child(inst, false, 0)
	queue_free()


func _on_run_button_pressed():
	click_sound.play()
	var r = RandomNumberGenerator.new().randf_range(0.0, 100.0)
	if r <= FightData.run_chance:
		ui.update_log("You got away safely!")
		run_audio.play()
		player_mon[0].run()
		FightData.run_chance -= 5.0
		end_combat()
	else:
		ui.update_log("you cannot escape!")
		end_turn()


func _on_reset_pressed():
		get_tree().reload_current_scene()
