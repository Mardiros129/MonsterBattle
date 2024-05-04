extends Area2D

@export var monster_options: Array[String]
@onready var monster_path: String
signal body_entered_return_path(body, path)

func _ready():
	if monster_options.size() > 0:
		var r = randi_range(0, monster_options.size() - 1)
		monster_path = monster_options[r]
		$RichTextLabel.text = monster_path
	else:
		$RichTextLabel.text = "no monsters here!"

func _on_body_entered(body):
	emit_signal("body_entered_return_path", body, monster_path)
