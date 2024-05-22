extends Node2D


@onready var player_turn = true
@onready var combat_finished = false

@onready var resolve_turn_timer = $ResolveTurnTimer
@onready var player_mon_loc = $PlayerMonLocation
@onready var enemy_mon_loc = $EnemyMonLocation
@onready var run_audio = $RunAudio

@onready var mon_start_lineup: Array # Maintain the original order for the whole game
@onready var player_mon: Array # Change the order by their combat role
# 0 = point, monster in combat
# 1 = first support
# 2 = second support
# 3 = standby

@onready var enemy_mon: Array
# 0 = point, monster in combat
# 1 = first support
# 2 = second support

#@onready var command_queue: Array
@export var command_delay = 0.4
@onready var bonus_turn = false # Currently only works for player, need to update later to include enemy

@onready var ui = $UI
@onready var end_button = $UI/EndButton
@onready var click_sound = $UI/ClickSound


func _ready():
	# Setup player party
	for x in MonsterParty.party.size():
		var new_monster = load(MonsterParty.party[x]).instantiate()
		mon_start_lineup.append(new_monster)
		player_mon.append(new_monster)
		
		for y in MonsterParty.party_moves[x].size():
			var new_move = load(MonsterParty.party_moves[x][y]).instantiate()
			new_monster.add_move(new_move)
	
	for x in player_mon.size():
		player_mon_loc.add_child(player_mon[x])
		player_mon[x].hide()
		player_mon[x].current_hp = MonsterParty.party_hp[x]
		player_mon[x].experience = MonsterParty.party_exp[x]
		player_mon[x].level = MonsterParty.party_level[x]
	
	player_mon[0].show()
	player_mon[0].reset_anim()
	
	# Setup enemy party
	for x in enemy_mon_loc.get_child_count():
		enemy_mon.append(enemy_mon_loc.get_child(x))
		enemy_mon[x].hide()
		enemy_mon[x].setup_enemy()
	
	enemy_mon[0].show()
	
	# Setup signals
	var all_monsters = player_mon + enemy_mon
	for x in all_monsters.size():
		var chosen_mon_attacks = all_monsters[x].move_list
		for y in chosen_mon_attacks.size():
			chosen_mon_attacks[y].combat_message.connect(_on_combat_message_received)
	
	# Setup UI
	ui.set_button_icons(player_mon)
	ui.set_catch_labels(PlayerInventory.catch_counter, FightData.catch_chance)
	ui.set_player_mon_ui(player_mon[0])
	ui.set_enemy_mon_ui(enemy_mon[0])
	start_turn()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


## *** *** COMBAT *** ***


func start_turn():
	FightData.catch_chance = 1.0 - float(enemy_mon[0].current_hp) / float(enemy_mon[0].max_hp)
	ui.enable_ui()
	ui.update_catch_chance(FightData.catch_chance)
	ui.player_mon_ui.update_mon_speed_ui(player_mon[0])
	ui.enemy_mon_ui.update_mon_speed_ui(enemy_mon[0])
	
	if !enemy_mon[0].catchable:
		ui.not_catchable_button()
	
	# Refactor later
	if player_mon.size() > 1:
		if player_mon[1].current_speed > enemy_mon[0].current_speed and not bonus_turn:
			ui.show_speed_icon(0)
	if player_mon.size() > 2:
		if player_mon[2].current_speed > enemy_mon[0].current_speed and not bonus_turn:
			ui.show_speed_icon(1)
	
	player_turn = true


func end_turn():
	player_turn = false
	ui.disable_ui()
	
	enemy_chooses_attack()
	
	# Go through everything in the queue one-by-one.
	while not CommandQueue.command_queue.is_empty():
		var command = CommandQueue.command_queue.pop_front()
		
		var attack_name
		if command.user == player_mon[0]:
			attack_name = player_mon[0].attack(command.move, enemy_mon[0])
		elif command.user == enemy_mon[0]:
			attack_name = enemy_mon[0].attack(command.move, player_mon[0])
			ui.populate_enemy_attacks(attack_name)
		
		ui.update_player_hp(player_mon[0])
		ui.update_enemy_hp(enemy_mon[0])
		
		check_player_death()
		check_enemy_death()
		
		await get_tree().create_timer(command_delay).timeout
		
		if player_mon.size() <= 0 or enemy_mon.size() <= 0:
			combat_finished = true
		
		if combat_finished:
			break
		
	if combat_finished:
		CommandQueue.clear_command_queue()
		end_combat()
	else:
		# Go through statuses
		for x in player_mon.size():
			player_mon[x].activate_all_statuses()
		for x in enemy_mon.size():
			enemy_mon[x].activate_all_statuses()
		
		check_player_death()
		check_enemy_death()
		
		ui.update_ui(player_mon, enemy_mon)
		CommandQueue.clear_command_queue()
		
		if not combat_finished:
			start_turn()


# To do, implement some AI behavior
func enemy_chooses_attack():
	var result = randi_range(0, enemy_mon[0].move_list.size() - 1)
	new_command(result, enemy_mon[0], player_mon[0])


func new_command(move, user, target):
	var speed
	if !bonus_turn:
		speed = user.current_speed
	elif user == player_mon[0]:
		# Always go last if it's a bonus turn (regular speed will never be less than 0)
		speed = -1
		bonus_turn = false
	
	CommandQueue.new_command_enqueue(move, user, target, speed)


func _player_damages_enemy(dmg):
	enemy_mon[0].take_damage(dmg)


func _on_combat_message_received(message: String):
	ui.update_log(message)


## *** *** DEATH *** ***


func check_player_death():
	if player_mon[0].current_hp <= 0:
			player_mon_dies()
			
			if player_mon[0].current_hp <= 0 and player_mon.size() == 1:
				end_combat()
				ui.update_log("You lose!")
				await get_tree().create_timer(command_delay).timeout


func player_mon_dies():
	player_mon[0].die()
	ui.update_log(player_mon[0].my_name + " died!")
	await get_tree().create_timer(command_delay).timeout

	if player_mon.size() > 1:
		player_mon.pop_front()
		player_mon[0].show()
		ui.set_player_mon_ui(player_mon[0])
		ui.set_button_icons(player_mon)


func check_enemy_death():
	if enemy_mon[0].current_hp <= 0:
			enemy_mon_dies()
			
			# Check if the game ends
			if enemy_mon.size() <= 1:
				end_combat()
				ui.update_log("You won!")
				await get_tree().create_timer(command_delay).timeout
				MonsterPool.pool_size -= 1


func enemy_mon_dies():
	enemy_mon[0].die()
	ui.update_log("Enemy " + enemy_mon[0].my_name + " died!")
	await get_tree().create_timer(command_delay).timeout
	
	enemy_mon.pop_front()
	player_mon[0].gain_exp(2)
	
	if enemy_mon.size() > 0:
		replace_enemy()


func replace_enemy():
	enemy_mon[0].show()
	ui.set_enemy_mon_ui(enemy_mon[0])


## *** *** ATTACK *** ***


func _on_attack_button_pressed():
	click_sound.play()
	ui.show_move_list()


func _on_move_0_pressed():
	choose_attack(0)


func _on_move_1_pressed():
	choose_attack(1)


func _on_move_2_pressed():
	choose_attack(2)


func _on_move_3_pressed():
	choose_attack(3)


func choose_attack(index):
	click_sound.play()
	new_command(index, player_mon[0], enemy_mon[0])
	end_turn()


## *** *** SWITCH *** ***


func switch(button_index):
	player_mon[0].hide()
	ui.swap_buttons(player_mon[0], button_index)
	ui.disable_ui()
	
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
	
	# Get a bonus turn if your speed is faster
	if player_mon[0].current_speed <= enemy_mon[0].current_speed:
		end_turn()
	else:
		ui.enable_ui()
		ui.disable_switch_buttons()
		bonus_turn = true


func _on_switch_button_0_pressed():
	click_sound.play()
	switch(0)


func _on_switch_button_1_pressed():
	click_sound.play()
	switch(1)


## *** *** SPELL *** ***


func _on_heal_button_pressed():
	PlayerInventory.potion_counter -= 1
	player_mon[0].heal_damage(FightData.spell_healing)
	
	ui.disable_ui()
	ui.update_player_hp(player_mon[0])
	ui.update_log("Healed " + str(FightData.spell_healing) + " with a spell!")
	await get_tree().create_timer(command_delay).timeout
	
	end_turn()


## *** *** CATCH *** ***


func _on_catch_button_pressed():
	PlayerInventory.catch_counter -= 1
	ui.update_catch_count(PlayerInventory.catch_counter)
	
	var result = randf()
	if result <= FightData.catch_chance:
		var caught_enemy = enemy_mon[0]
		caught_enemy.catch_anim()
		ui.update_log("Catch successful!")
		#await get_tree().create_timer(command_delay).timeout
		await get_tree().create_timer(1.0).timeout
		
		MonsterPool.pool_size -= 1
		enemy_mon_loc.remove_child(caught_enemy)
		enemy_mon.pop_front()
		
		# Add to party
		if player_mon.size() < 4:
			add_monster_to_party(caught_enemy)
		else:
			# TODO: send to box
			pass
		
		if enemy_mon.size() > 0:
			replace_enemy()
			start_turn()
		else:
			end_combat()
	
	else:
		ui.update_log("Catch failed...")
		await get_tree().create_timer(command_delay).timeout
		
		end_turn()


func add_monster_to_party(monster):
	player_mon_loc.add_child(monster)
	monster.reset_anim()
	monster.hide()
	player_mon.append(monster)
	mon_start_lineup.append(monster)
	ui.set_button_icons(player_mon)


## *** *** RUN *** ***


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


## *** *** END *** ***


func end_combat():
	combat_finished = true
	ui.disable_ui()
	end_button.show()

func _on_end_button_pressed():
	click_sound.play()
 	# Setup party, exclude slain allies, include captured enemy
	MonsterParty.clear_all()
	for x in mon_start_lineup.size():
		var current_mon = mon_start_lineup[x]
		if current_mon != null:
			MonsterParty.save_party_member(mon_start_lineup[x])
	
	# Load next scene
	var inst = load("res://Levels/end_screen.tscn").instantiate()
	get_tree().root.add_child(inst)
	queue_free()


func _on_reset_pressed():
		get_tree().reload_current_scene()


