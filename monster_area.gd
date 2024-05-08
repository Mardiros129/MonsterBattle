extends Area2D

@export var monster_options: Array[String]
@onready var monster_path: String
@export var encounter_chance = 0.0015
@onready var player_in_zone = false
@onready var player_body
@onready var prev_player_pos

signal body_entered_return_path(body, path)

func _ready():
	# Refactor later
	if monster_options.size() > 0:
		var r = randi_range(0, monster_options.size() - 1)
		monster_path = monster_options[r]
		$RichTextLabel.text = monster_path
	elif MonsterPool.pool.size() > 0:
		var r = randi_range(0, MonsterPool.pool.size() - 1)
		monster_path = MonsterPool.pool[r]
		$RichTextLabel.text = monster_path
	else:
		$RichTextLabel.text = "no monsters here!"

func _process(delta):
	if player_in_zone:
		print_debug(player_body.position)
		
		if prev_player_pos != player_body.position:
			prev_player_pos = player_body.position
			var r = RandomNumberGenerator.new().randf()
			if r <= encounter_chance && MonsterPool.pool_size > 0:
				emit_signal("body_entered_return_path", player_body, monster_path)

func _on_body_entered(body):
	player_in_zone = true
	player_body = body
	prev_player_pos = player_body.position

func _on_body_exited(body):
	player_in_zone = false
	player_body = null
	prev_player_pos = null
