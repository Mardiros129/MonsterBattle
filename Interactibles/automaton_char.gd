extends "res://Classes/interactible.gd"


signal start_fight(path: String)

@onready var dialog0 = $Dialog0
@onready var battery_button = $BatteryButton
@onready var monster_path = ["res://Monsters/automaton.tscn"] # All fights need an array of paths to start


func start_interaction():
	dialog_timer.timeout.connect(_on_dialog_timer_timeout) # Gets dc'd if scene is reloaded
	dialog_timer.start()
	dialog0.show()
	if PlayerInventory.unique_items.has("Battery"):
		battery_button.show()


func _on_dialog_timer_timeout():
	dialog0.hide()
	battery_button.hide()


func _on_battery_button_pressed():
	PlayerInventory.unique_items.erase("Battery")
	start_fight.emit(null, monster_path)
