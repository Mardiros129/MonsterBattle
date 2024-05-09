extends Area2D

@export var monster_options: Array[String]
@onready var monster_path: String
@export var encounter_chance = 0.0015
@onready var player_in_zone = false
@onready var player_body
@onready var prev_player_pos
@export var check_monster_pool = true

signal body_entered_return_path(body, path)

func _ready():
	if check_monster_pool:
		var r = randi_range(0, MonsterPool.pool.size() - 1)
		monster_path = MonsterPool.pool[r]
	else:
		var r = randi_range(0, monster_options.size() - 1)
		monster_path = monster_options[r]
	
	$RichTextLabel.text = monster_path

func _process(delta):
	if player_in_zone:
		print_debug(player_body.position)
		
		if prev_player_pos != player_body.position:
			prev_player_pos = player_body.position
			var r = RandomNumberGenerator.new().randf()
			if r <= encounter_chance:
				if MonsterPool.pool_size > 0 || !check_monster_pool:
					emit_signal("body_entered_return_path", player_body, monster_path)

func _on_body_entered(body):
	player_in_zone = true
	player_body = body
	prev_player_pos = player_body.position

func _on_body_exited(body):
	player_in_zone = false
	player_body = null
	prev_player_pos = null
