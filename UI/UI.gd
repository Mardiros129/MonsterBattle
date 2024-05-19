extends Control


@onready var switch_button0 = $SwitchButton0
@onready var switch_button1 = $SwitchButton1
@onready var sideboard = $Sideboard
@onready var switch_buttons = [switch_button0, switch_button1, sideboard]

@onready var attack_button = $AttackButton
@onready var spell_button = $SpellButton
@onready var catch_button = $CatchButton
@onready var run_button = $RunButton

@onready var spellbook = $Spellbook
@onready var closed_book = $ClosedBook

@export var number_of_moves = 4
@onready var player_move_list = $PlayerMoveList
@onready var enemy_move_list = $EnemyMoveList
@export var enemy_move_missing_text = "???"

@onready var player_spell_list = $PlayerSpellList
@onready var potion_button = $PlayerSpellList/PotionButton

@onready var catch_count_label = $CatchCount
@onready var catch_chance_label = $CatchChance
@onready var combat_log = $CombatLog

@onready var player_mon_ui = $PlayerMonUI
@onready var enemy_mon_ui = $EnemyMonUI

@onready var type_matchup_button = $TypeMatchupButton
@onready var type_matchup_chart = $TypeMatchupChart

@onready var player_move_details = $PlayerMoveDetails

@onready var click_sound = $ClickSound

@onready var party_size := 1


func _ready():
	if PlayerInventory.catch_counter <= 0 || FightData.catch_chance <= 0.0:
		catch_button.disabled = true
	
	for x in enemy_move_list.item_count:
		enemy_move_list.set_item_text(x, enemy_move_missing_text)
	
	if FightData.boss_fight:
		run_button.disabled = true
		run_button.text = "Can't run!"
	else:
		run_button.text = "Run! (" + str(FightData.run_chance) + "%)"


func set_catch_labels(catch_count, catch_chance):
	catch_count_label.text = "Blank page count: " + str(catch_count)
	catch_chance_label.text = "Catch chance: " + str(catch_chance * 100) + "%"


func set_button_icons(mon_team):
	party_size = mon_team.size() # Maybe remove later
	
	for x in switch_buttons.size():
		if mon_team.size() > x + 1:
			switch_buttons[x].set_button_icon(mon_team[x + 1].get_sprite())
			if switch_buttons[x] != sideboard:
				switch_buttons[x].disabled = false
		else:
			switch_buttons[x].set_button_icon(null)
			switch_buttons[x].disabled = true


func set_player_mon_ui(player_mon):
	player_mon_ui.set_mon_ui(player_mon)
	set_moves(player_mon)


func change_player_hp(player_mon):
	player_mon_ui.set_mon_hp_ui(player_mon)


func set_enemy_mon_ui(enemy_mon):
	for x in enemy_move_list.item_count:
		enemy_move_list.set_item_text(x, enemy_move_missing_text)
	enemy_mon_ui.set_mon_ui(enemy_mon)


func change_enemy_hp(enemy_mon):
	enemy_mon_ui.set_mon_hp_ui(enemy_mon)


func show_move_list():
	player_move_list.show()
	player_spell_list.hide()


func show_spell_list():
	player_spell_list.show()
	player_move_list.hide()
	
	potion_button.text = "Heal x" + str(PlayerInventory.potion_counter)
	
	if PlayerInventory.potion_counter <= 0:
		potion_button.disabled = true


func update_catch_count(catch_count):
	catch_count_label.text = "Blank card count: " + str(catch_count)


func update_catch_chance(catch_chance):
	catch_button.text = "Catch (" + str(int(catch_chance * 100)) + "%)"


func disable_ui():
	attack_button.disabled = true
	spell_button.disabled = true
	catch_button.disabled = true
	run_button.disabled = true
	
	player_move_list.hide()
	hide_all_move_details()
	player_spell_list.hide()
	
	type_matchup_button.disabled = true
	disable_switch_buttons()
	
	spellbook.hide()
	closed_book.show()


func disable_switch_buttons():
	for x in switch_buttons.size():
		switch_buttons[x].disabled = true


func enable_ui():
	attack_button.disabled = false
	spell_button.disabled = false
	
	if not FightData.boss_fight:
		run_button.disabled = false
	
	type_matchup_button.disabled = false
	
	if party_size > 1:
		switch_button0.disabled = false
	
	if party_size > 2:
		switch_button1.disabled = false
	
	if PlayerInventory.catch_counter > 0 && FightData.catch_chance > 0.0:
		catch_button.disabled = false


func swap_buttons(player_mon, index):
	var new_icon = player_mon.get_node("Sprite2D").texture
	switch_buttons[index].set_button_icon(new_icon)


func not_catchable_button():
	catch_button.disabled = true
	catch_button.text = "Can't catch!"


func set_moves(player_mon):
	for x in number_of_moves:
		var move_button = player_move_list.get_child(x)
		
		if player_mon.move_list.size() > x:
			move_button.find_child("Label").text = player_mon.move_list[x].attack_name
			move_button.disabled = false
			
			var attack_details = player_move_details.get_child(x)
			attack_details.set_attack_details(player_mon.move_list[x])
		else:
			move_button.hide()


func populate_enemy_attacks(move_name: String) -> void:
	for x in enemy_move_list.item_count:
		if enemy_move_list.get_item_text(x) == move_name:
			break
		if enemy_move_list.get_item_text(x) == enemy_move_missing_text:
			enemy_move_list.set_item_text(x, move_name)
			break


func update_log(info: String):
	combat_log.text = combat_log.text + "\n" + info
	combat_log.text += "\n" + "---------------------------"


func _on_attack_button_pressed():
	spellbook.show()
	closed_book.hide()


func _on_spell_button_pressed():
	click_sound.play()
	show_spell_list()
	hide_all_move_details()
	spellbook.show()
	closed_book.hide()


func _on_type_matchup_button_pressed():
	click_sound.play()
	if type_matchup_chart.visible:
		type_matchup_chart.hide()
	else:
		type_matchup_chart.show()


func hover_move_button(index):
	hide_all_move_details()
	player_move_details.get_child(index).show()


func hide_all_move_details():
	for n in player_move_details.get_child_count():
		player_move_details.get_child(n).hide()


func _on_move_0_mouse_entered():
	hover_move_button(0)


func _on_move_1_mouse_entered():
	hover_move_button(1)


func _on_move_2_mouse_entered():
	hover_move_button(2)


func _on_move_3_mouse_entered():
	hover_move_button(3)


func _on_switch_button_0_pressed():
	player_move_list.hide()
	hide_all_move_details()


func _on_switch_button_1_pressed():
	player_move_list.hide()
	hide_all_move_details()
