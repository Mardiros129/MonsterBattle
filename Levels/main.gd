extends Node2D

@onready var player_turn = true

@onready var player_mon
@onready var mon_team: Array
@onready var switch_buttons: Array
@onready var enemy_mon = $EnemyMonster

# To do, move to UI scene
@onready var ui = $UI
@onready var attack_button = $UI/AttackButton
@onready var catch_button = $UI/CatchButton
@onready var move_list = $UI/PlayerAttackList
@onready var catch_count_label = $UI/CatchCount
@onready var catch_chance_label = $UI/CatchChance
@onready var enemy_turn_timer = $EnemyTurnTimer

@export var catch_count = 5
@export var catch_chance = 0.1

@export var player_monster0: Node2D
@export var player_monster1: Node2D
@export var player_monster2: Node2D
@export var player_monster3: Node2D


func _ready():
	mon_team.append(player_monster0)
	mon_team.append(player_monster1)
	mon_team.append(player_monster2)
	mon_team.append(player_monster3)
	
	switch_buttons.append($UI/SwitchButton0)
	switch_buttons.append($UI/SwitchButton1)
	switch_buttons.append($UI/SwitchButton2)
	
	for x in switch_buttons.size():
		switch_buttons[x].set_button_icon(mon_team[x+1].get_node("Sprite2D").texture)
	
	# Signals
	for x in mon_team.size():
		mon_team[x].mon_dies.connect(_player_mon_dies)
		mon_team[x].damage_enemy.connect(_player_damages_enemy)
	
	player_mon = mon_team[0]
	mon_team.pop_front()
	
	set_moves()
	
	move_list.select(0)
	catch_count_label.text = "Catch count: " + str(catch_count)
	catch_chance_label.text = "Catch chance: " + str(catch_chance * 100) + "%"

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func end_turn():
	enemy_turn_timer.start()
	attack_button.disabled = true
	catch_button.disabled = true
	for x in switch_buttons.size():
		switch_buttons[x].disabled = true
	player_turn = false

func start_turn():
	attack_button.disabled = false
	
	if catch_count > 0:
		catch_button.disabled = false
	
	for x in switch_buttons.size():
		switch_buttons[x].disabled = false
	
	player_turn = true

# Consider refactoring
func set_moves():
	if player_mon.attack0 != null:
		move_list.set_item_text(0, player_mon.attack0.attack_name)
		move_list.set_item_disabled(0, false)
	else:
		move_list.set_item_text(0, "null")
		move_list.set_item_disabled(0, true)
	
	if player_mon.attack1 != null:
		move_list.set_item_text(1, player_mon.attack1.attack_name)
		move_list.set_item_disabled(1, false)
	else:
		move_list.set_item_text(1, "null")
		move_list.set_item_disabled(1, true)
	
	if player_mon.attack2 != null:
		move_list.set_item_text(2, player_mon.attack2.attack_name)
		move_list.set_item_disabled(2, false)
	else:
		move_list.set_item_text(2, "null")
		move_list.set_item_disabled(2, true)
	
	if player_mon.attack3 != null:
		move_list.set_item_text(3, player_mon.attack3.attack_name)
		move_list.set_item_disabled(3, false)
	else:
		move_list.set_item_text(3, "null")
		move_list.set_item_disabled(3, true)

func switch(index):
	player_mon.visible = false
	switch_buttons[index].set_button_icon(player_mon.get_node("Sprite2D").texture)
	
	var temp = player_mon
	player_mon = mon_team[index]
	mon_team[index] = temp
	
	player_mon.visible = true
	set_moves()
	end_turn()

func _on_reset_pressed():
		get_tree().reload_current_scene()

func _on_attack_button_pressed():
	player_mon.attack(move_list.get_selected_items()[0])
	end_turn()

func _on_enemy_turn_timer_timeout():
	if enemy_mon != null:
		player_mon.take_damage(1)
		start_turn()

func _on_catch_button_pressed():
	catch_count -= 1
	catch_count_label.text = "Catch count: " + str(catch_count)
	if catch_count <= 0:
		catch_button.disabled = true
	
	var rng = RandomNumberGenerator.new()
	var result = rng.randf()
	if result <= catch_chance:
		print("success!")
		enemy_mon.queue_free()
	else:
		print("failure")
	
	end_turn()

func _on_switch_button_0_pressed():
	switch(0)

func _on_switch_button_1_pressed():
	switch(1)

func _on_switch_button_2_pressed():
	switch(2)

func _player_mon_dies():
	if mon_team.size() > 0:
		for x in switch_buttons.size() - 1:
			switch_buttons[x].set_button_icon(switch_buttons[x+1].icon)
	
		var last_button = switch_buttons.pop_back()
		last_button.icon = null
		last_button.disabled = true
		
		player_mon = mon_team.pop_front()
		player_mon.visible = true

func _player_damages_enemy(dmg):
	print(str(dmg) + " damage!")
	enemy_mon.take_damage(dmg)
