extends CharacterBody2D


const SPEED = 300.0
@onready var sprite = $Sprite2D


func _physics_process(delta):
	var direction_x = Input.get_axis("ui_left", "ui_right")
	if direction_x > 0:
		sprite.flip_h = false
	elif direction_x < 0:
		sprite.flip_h = true
	
	if direction_x:
		velocity.x = direction_x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var direction_y = Input.get_axis("ui_up", "ui_down")
	if direction_y:
		velocity.y = direction_y
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	velocity = velocity.normalized() * SPEED
	move_and_slide()
