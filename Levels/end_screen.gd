extends Node2D

@onready var party_summary = $PartySummary
@onready var lose_label = $LoseLabel
@onready var explore_button = $ExploreButton


func _ready():
	if MonsterParty.party.size() == 0:
		lose_label.show()
		explore_button.text = "End"
	
	party_summary.setup_ui()


func go_to_world():
	var inst = WorldLoad.world
	get_tree().root.add_child(inst)
	queue_free()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			go_to_world()


func _on_button_pressed():
	if MonsterParty.party.size() == 0:
		get_tree().quit()
	else:
		go_to_world()
