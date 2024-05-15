extends Area2D


signal body_entered_return_path(body, path)

@export var monster_options: Array[String]
@onready var monster_paths: Array[String]

@onready var player_in_zone = false
@onready var player_body
@onready var prev_player_pos

@export var encounter_chance = 0.0015
@export var check_monster_pool = true
@export var encounter_size = 1
@export var boss_fight = false


func _ready():
	for x in encounter_size:
		if check_monster_pool:
			var r = randi_range(0, MonsterPool.pool.size() - 1)
			monster_paths.append(MonsterPool.pool[r])
		else:
			monster_paths.append(monster_options[x])


func _process(delta):
	if player_in_zone:
		if prev_player_pos != player_body.position:
			prev_player_pos = player_body.position
			var r = RandomNumberGenerator.new().randf()
			if r <= encounter_chance:
				if MonsterPool.pool_size > 0 || !check_monster_pool:
					FightData.boss_fight = boss_fight
					emit_signal("body_entered_return_path", player_body, monster_paths)


func _on_body_entered(body):
	player_in_zone = true
	player_body = body
	prev_player_pos = player_body.position


func _on_body_exited(body):
	player_in_zone = false
	player_body = null
	prev_player_pos = null
