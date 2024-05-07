extends StaticBody2D


@onready var dialog_0 = $Dialog0
@onready var dialog_1 = $Dialog1
@onready var player_facing
@onready var timer = $Timer
@onready var monster_path = "res://Monsters/automaton.tscn" # If exported, can't reload into scene
signal start_fight(path: String)


func _ready():
	#get_parent().get_parent().connect("start_fight", monster_path)
	pass

func _unhandled_input(event):
	var has_battery = false
	for x in PlayerInventory.unique_items.size():
		if PlayerInventory.unique_items[x] == "Battery":
			has_battery = true
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE && player_facing:
			if !has_battery:
				dialog_0.show()
				timer.start()
			else:
				dialog_0.hide()
				dialog_1.show()

func _on_interactable_area_entered(area):
	player_facing = true

func _on_interactable_area_exited(area):
	player_facing = false

func _on_timer_timeout():
	dialog_0.hide()

func _on_fight_button_pressed():
	queue_free()
	await get_tree().create_timer(1.0).timeout
	start_fight.emit(monster_path)

func _on_run_button_pressed():
	queue_free()
