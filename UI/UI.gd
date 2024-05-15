extends Control


@onready var switch_button0 = $SwitchButton0
@onready var switch_button1 = $SwitchButton1
@onready var sideboard = $Sideboard
@onready var switch_buttons: Array

@onready var attack_button = $AttackButton
@onready var item_button = $ItemButton
@onready var catch_button = $CatchButton
@onready var run_button = $RunButton

@export var number_of_attacks = 4
@onready var move_list = $PlayerAttackList
@onready var enemy_attack_list = $EnemyAttackList
@export var enemy_attack_missing_text = "???"

@onready var inventory = $Inventory
@onready var catch_count_label = $CatchCount
@onready var catch_chance_label = $CatchChance
@onready var combat_log = $CombatLog

@onready var player_mon_ui = $PlayerMonUI
@onready var enemy_mon_ui = $EnemyMonUI

@onready var type_matchup_button = $TypeMatchupButton
@onready var type_matchup_chart = $TypeMatchupChart

@onready var player_attack_details = $PlayerAttackDetails

@onready var click_sound = $ClickSound


func _ready():
	inventory.select(0, true)
	if PlayerInventory.catch_counter <= 0 || FightData.catch_chance <= 0.0:
		catch_button.disabled = true
	
	for x in enemy_attack_list.item_count:
		enemy_attack_list.set_item_text(x, enemy_attack_missing_text)
	
	if FightData.boss_fight:
		run_button.disabled = true
		run_button.text = "Can't run!"
	else:
		run_button.text = "Run! (" + str(FightData.run_chance) + "%)"


func set_catch_labels(catch_count, catch_chance):
	catch_count_label.text = "Blank card count: " + str(catch_count)
	catch_chance_label.text = "Catch chance: " + str(catch_chance * 100) + "%"


func set_button_icons(mon_team):
	if mon_team.size() > 1:
		switch_buttons.append(switch_button0)
		switch_buttons[0].set_button_icon(mon_team[1].get_node("Sprite2D").texture)
		switch_buttons[0].disabled = false
		if mon_team.size() > 2:
			switch_buttons.append(switch_button1)
			switch_buttons[1].set_button_icon(mon_team[2].get_node("Sprite2D").texture)
			switch_buttons[1].disabled = false
			if mon_team.size() > 3:
				switch_buttons.append(sideboard)
				sideboard.set_button_icon(mon_team[3].get_node("Sprite2D").texture)


func set_player_mon_ui(player_mon):
	player_mon_ui.set_mon_ui(player_mon)
	set_moves(player_mon)


func change_player_hp(player_mon):
	player_mon_ui.set_mon_hp_ui(player_mon)


func set_enemy_mon_ui(enemy_mon):
	for x in enemy_attack_list.item_count:
		enemy_attack_list.set_item_text(x, enemy_attack_missing_text)
	enemy_mon_ui.set_mon_ui(enemy_mon)


func change_enemy_hp(enemy_mon):
	enemy_mon_ui.set_mon_hp_ui(enemy_mon)


func get_selected_move():
	var move = move_list.get_selected_items()[0]
	return move


func update_catch_count(catch_count):
	catch_count_label.text = "Blank card count: " + str(catch_count)


func update_catch_chance(catch_chance):
	catch_button.text = "Catch (" + str(int(catch_chance * 100)) + "%)"


func disable_ui():
	attack_button.disabled = true
	item_button.disabled = true
	catch_button.disabled = true
	run_button.disabled = true
	
	for x in move_list.item_count:
		move_list.set_item_disabled(x, true)
	player_attack_details.hide()
	
	type_matchup_button.disabled = true
	disable_switch_buttons()


func disable_switch_buttons():
	for x in switch_buttons.size():
		switch_buttons[x].disabled = true


func enable_ui():
	attack_button.disabled = false
	item_button.disabled = false
	
	if not FightData.boss_fight:
		run_button.disabled = false
	
	for x in move_list.item_count:
		move_list.set_item_disabled(x, false)
	player_attack_details.show()
	
	type_matchup_button.disabled = false
	
	if switch_buttons.size() > 0:
		switch_button0.disabled = false
	
	if switch_buttons.size() > 1:
		switch_button1.disabled = false
	
	if PlayerInventory.catch_counter > 0 && FightData.catch_chance > 0.0:
		catch_button.disabled = false


func swap_buttons(player_mon, index):
	var new_icon = player_mon.get_node("Sprite2D").texture
	switch_buttons[index].set_button_icon(new_icon)


func not_catchable_button():
	catch_button.disabled = true
	catch_button.text = "Can't catch!"


func pop_button():
	for x in switch_buttons.size() - 1:
		switch_buttons[x].set_button_icon(switch_buttons[x+1].icon)
	var last_button = switch_buttons.pop_back()
	last_button.icon = null
	last_button.disabled = true


func set_moves(player_mon):
	for x in number_of_attacks:
		if player_mon.attack_list.size() > x:
			move_list.set_item_text(x, player_mon.attack_list[x].attack_name)
			move_list.set_item_disabled(x, false)
			
			var attack_details = player_attack_details.get_child(x)
			attack_details.set_attack_details(player_mon.attack_list[x])
		else:
			move_list.set_item_text(x, "null")
			move_list.set_item_disabled(x, true)
	
	move_list.select(0)


func populate_enemy_attacks(attack_name: String) -> void:
	for x in enemy_attack_list.item_count:
		if enemy_attack_list.get_item_text(x) == attack_name:
			break
		if enemy_attack_list.get_item_text(x) == enemy_attack_missing_text:
			enemy_attack_list.set_item_text(x, attack_name)
			break


func update_log(info: String):
	combat_log.text = combat_log.text + "\n" + info
	combat_log.text += "\n" + "---------------------------"


func _on_item_button_pressed():
	var item_choice = inventory.get_selected_items()[0]
	print(item_choice)
	click_sound.play()


func _on_type_matchup_button_pressed():
	click_sound.play()
	if type_matchup_chart.visible:
		type_matchup_chart.hide()
	else:
		type_matchup_chart.show()


func _on_player_attack_list_item_selected(index):
	for n in player_attack_details.get_child_count():
		player_attack_details.get_child(n).hide()
	player_attack_details.get_child(index).show()
