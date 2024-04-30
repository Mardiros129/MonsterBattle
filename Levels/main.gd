extends Node2D

@onready var player_mon = $PlayerMonster
@onready var enemy_mon = $EnemyMonster

@onready var attack_button = $AttackButton
@onready var move_list = $MoveList

@onready var player_turn = true
@onready var enemy_turn_timer = $EnemyTurnTimer


func _ready():
	move_list.select(0)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func end_turn():
	enemy_turn_timer.start()
	attack_button.disabled = true
	player_turn = false

func start_turn():
	attack_button.disabled = false
	player_turn = true

func _on_attack_button_pressed():
	match move_list.get_selected_items()[0]:
		0:
			enemy_mon.take_damage(2)
		1:
			enemy_mon.heal_damage(1)
		2:
			player_mon.heal_damage(2)
	end_turn()

func _on_enemy_turn_timer_timeout():
	player_mon.take_damage(1)
	start_turn()
