extends CharacterBody2D


@export var speed = 300.0
@onready var sprite = $Sprite2D
@onready var pickup_offset
@onready var pickup_area = $PickupArea
@onready var facing_item
@onready var frozen = false
@onready var animation_player = $AnimationPlayer

enum Direction { UP, DOWN, LEFT, RIGHT }
@onready var facing: Direction


func _ready():
	pickup_offset = abs(pickup_area.position.x + pickup_area.position.y)


func _physics_process(_delta):
	# Move the player
	if not frozen:
		var direction_x = Input.get_axis("move_left", "move_right")
		if direction_x:
			velocity.x = direction_x
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		var direction_y = Input.get_axis("move_up", "move_down")
		if direction_y:
			velocity.y = direction_y
		else:
			velocity.y = move_toward(velocity.y, 0, speed)
		
		# Flip the sprite
		if direction_y > 0:
			pickup_area.position.y = pickup_offset
			pickup_area.position.x = 0
			facing = Direction.DOWN
		elif direction_y < 0:
			pickup_area.position.y = - pickup_offset
			pickup_area.position.x = 0
			facing = Direction.UP
		if direction_x > 0:
			pickup_area.position.x = pickup_offset
			pickup_area.position.y = 0
			facing = Direction.RIGHT
		elif direction_x < 0:
			pickup_area.position.x = -pickup_offset
			pickup_area.position.y = 0
			facing = Direction.LEFT
		
		velocity = velocity.normalized() * speed
		move_and_slide()
		
		if velocity.x > 0 or velocity.y > 0:
			match facing:
				Direction.UP:
					animation_player.play("move_up")
				Direction.DOWN:
					animation_player.play("move_down")
				Direction.LEFT:
					animation_player.play("move_left")
				Direction.RIGHT:
					animation_player.play("move_right")
		else:
			match facing:
				Direction.UP:
					animation_player.play("idle_up")
				Direction.DOWN:
					animation_player.play("idle_down")
				Direction.LEFT:
					animation_player.play("idle_left")
				Direction.RIGHT:
					animation_player.play("idle_right")


func freeze():
	frozen = true


func unfreeze():
	frozen = false


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			pickup_item()


func pickup_item():
	if facing_item != null:
		facing_item.pickup()


func _on_pickup_area_body_entered(body):
	if body.is_in_group("Item"):
		facing_item = body


func _on_pickup_area_body_exited(body):
	if body.is_in_group("Item"):
		facing_item = null
