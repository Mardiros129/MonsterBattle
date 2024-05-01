extends Node2D


@onready var player_mon
@onready var support_mon0
@onready var support_mon1
@onready var sideboard_mon
@onready var mon_team: Array
@onready var player_turn = true
@onready var enemy_turn_timer = $EnemyTurnTimer

@export var player_monster0: Node2D
@export var player_monster1: Node2D
@export var player_monster2: Node2D
@export var player_monster3: Node2D
@export var enemy_mon: Node2D

@export var catch_count = 5
@export var catch_chance = 0.1

@onready var ui = $UI


func _ready():
	mon_team.append(player_monster0)
	mon_team.append(player_monster1)
	mon_team.append(player_monster2)
	mon_team.append(player_monster3)
	
	# Signals
	for x in mon_team.size():
		mon_team[x].mon_dies.connect(_player_mon_dies)
		mon_team[x].damage_enemy.connect(_player_damages_enemy)
	
	player_mon = mon_team[0]
	support_mon0 = mon_team[1]
	support_mon1 = mon_team[2]
	sideboard_mon = mon_team[3]
	
	ui.set_moves(player_mon)
	ui.set_button_icons(mon_team)
	ui.set_catch_labels(catch_count, catch_chance)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func end_turn():
	enemy_turn_timer.start()
	ui.disable_ui()
	player_turn = false

func start_turn():
	ui.enable_ui(catch_count, mon_team.size())
	player_turn = true

func switch(button_index):
	player_mon.visible = false
	ui.swap_buttons(player_mon, button_index)
	
	var temp = player_mon
	player_mon = mon_team[button_index + 1]
	mon_team[button_index + 1] = temp
	
	player_mon.visible = true
	ui.set_moves(player_mon)
	end_turn()

func _on_reset_pressed():
		get_tree().reload_current_scene()

func _on_attack_button_pressed():
	player_mon.attack(ui.get_selected_move(), enemy_mon.type1, enemy_mon.type2)
	end_turn()

func _on_enemy_turn_timer_timeout():
	# Enemy uses a random attack
	# To do: also use healing ability
	# To do: more intelligent AI behavior
	if enemy_mon != null:
		var rng = RandomNumberGenerator.new()
		var result = rng.randi_range(0, enemy_mon.attack_list.size()-1)
		var damage = enemy_mon.attack(result, player_mon.type1, player_mon.type2)
		player_mon.take_damage(damage)
		start_turn()

func _on_catch_button_pressed():
	catch_count -= 1
	ui.update_catch_count(catch_count)
	
	var rng = RandomNumberGenerator.new()
	var result = rng.randf()
	if result <= catch_chance:
		print("success!")
		enemy_mon.queue_free()
	else:
		print("failure")
	
	end_turn()

func _player_mon_dies():
	if mon_team.size() > 1:
		mon_team.pop_front()
		player_mon.queue_free()
		player_mon = mon_team[0]
		player_mon.visible = true
		ui.set_moves(player_mon)
		ui.pop_button()
	else:
		print("You lose!")
		player_mon.queue_free()
		ui.disable_ui()

func _player_damages_enemy(dmg):
	enemy_mon.take_damage(dmg)
	if enemy_mon.current_hp <= 0:
		enemy_mon.queue_free()

func _on_switch_button_0_pressed():
	switch(0)

func _on_switch_button_1_pressed():
	switch(1)
