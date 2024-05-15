extends Node2D


@onready var timer = $AudioDelay
@onready var click_sound = $ClickSound
@export var catch_counter = 0
@export var pool_size = 0
@export var monster_pool: Array[String]


func _ready():
	PlayerInventory.catch_counter = catch_counter
	MonsterPool.pool_size = pool_size
	MonsterPool.pool = monster_pool


func create_party_member(path):
	var mon_inst = load(path).instantiate(false)
	MonsterParty.new_add_to_party(mon_inst)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			start_game()


func start_game():
	get_tree().change_scene_to_file("res://Levels/world.tscn")


func _on_button_pressed():
	start_game()


func _on_animal_starter_pressed():
	click_sound.play()
	create_party_member("res://Monsters/rat.tscn")
	timer.start()


func _on_plant_starter_pressed():
	click_sound.play()
	create_party_member("res://Monsters/sprout.tscn")
	timer.start()


func _on_undead_starter_pressed():
	click_sound.play()
	create_party_member("res://Monsters/skeleton.tscn")
	timer.start()


func _on_timer_timeout():
	start_game()
