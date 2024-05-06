extends Node2D

@onready var character = $Character


func _ready():
	# The default value should always be out of bounds so the player will start where they are placed
	if Player.position != Vector2(-9999999.99, -9999999.99):
		character.position = Player.position

func load_enemy_battle(enemy_path):
	Player.position = character.position
	
	var battle_inst = load("res://Levels/main.tscn").instantiate(false)
	var enemy_inst = load(enemy_path).instantiate(false)
	var enemy_loc = battle_inst.find_child("EnemyMonLocation", false, false)
	enemy_loc.add_child(enemy_inst, false, false)
	
	get_tree().root.add_child(battle_inst, false, 0)
	queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_monster_area_body_entered_return_path(body, path):
	if path != "":
		load_enemy_battle(path)
