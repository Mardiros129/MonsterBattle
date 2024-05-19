extends "res://Classes/interactible.gd"


signal update_ui
@export var summoned_monster : PackedScene
@onready var button_group = $DialogControl/ButtonGroup
@onready var dialog_0 = $DialogControl/Dialog0
@onready var end_dialog = $DialogControl/EndDialog


func special_interaction():
	for x in button_group.get_child_count():
		button_group.get_child(x).hide()
	for x in MonsterParty.party.size():
		button_group.get_child(x).show()


func sacrifice(index):
	var new_monster = summoned_monster.instantiate()
	var path = new_monster.get_scene_file_path()
	
	add_child(new_monster)
	new_monster.hide()
	
	dialog_control.hide()
	button_group.hide()
	dialog_0.hide()
	end_dialog.show()
	
	MonsterParty.pop_at(index)
	MonsterParty.new_add_to_party(path)
	
	update_ui.emit()


func _on_button_0_pressed():
	sacrifice(0)


func _on_button_1_pressed():
	sacrifice(1)


func _on_button_2_pressed():
	sacrifice(2)


func _on_button_3_pressed():
	sacrifice(3)
