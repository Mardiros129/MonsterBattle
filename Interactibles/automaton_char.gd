extends "res://Classes/interactible.gd"


signal start_fight(path: String)

@onready var battery_button = $DialogControl/BatteryButton
@onready var monster_path = ["res://Monsters/automaton.tscn"] # All fights need an array of paths to start


func special_interaction():
	if PlayerInventory.unique_items.has("Battery"):
		battery_button.show()


func _on_battery_button_pressed():
	PlayerInventory.unique_items.erase("Battery")
	delete_me()
	start_fight.emit(null, monster_path)
