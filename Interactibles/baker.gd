extends "res://Classes/interactible.gd"


signal update_mon_hud(monster, index)

@onready var bake_button = $DialogControl/BakeButton
@onready var path = "res://Monsters/petuffin.tscn"
@onready var dialog_0 = $DialogControl/Dialog0
@onready var end_dialog = $DialogControl/EndDialog


func special_interaction():
	if (PlayerInventory.unique_items.has("Egg") 
			and PlayerInventory.unique_items.has("Sugar") 
			and PlayerInventory.unique_items.has("Flour")):
		
		bake_button.show()


func _on_bake_button_pressed():
	bake_button.hide()
	dialog_0.hide()
	end_dialog.show()
	dialog_control.hide()
	
	PlayerInventory.unique_items.erase("Egg")
	PlayerInventory.unique_items.erase("Sugar")
	PlayerInventory.unique_items.erase("Flour")
	
	print(path)
	MonsterParty.new_add_to_party(path)
	var n = MonsterParty.party.size() - 1
	
	var mon_inst = load(path).instantiate()
	mon_inst.hide()
	add_child(mon_inst)
	update_mon_hud.emit(mon_inst, n)
