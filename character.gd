extends CharacterBody2D


@export var SPEED = 300.0
@onready var sprite = $Sprite2D
@onready var pickup_offset
@onready var pickup_area = $PickupArea
@onready var facing_item

func _ready():
	pickup_offset = abs(pickup_area.position.x + pickup_area.position.y)

func _physics_process(delta):
	# Move the player
	var direction_x = Input.get_axis("move_left", "move_right")
	if direction_x:
		velocity.x = direction_x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var direction_y = Input.get_axis("move_up", "move_down")
	if direction_y:
		velocity.y = direction_y
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Flip the sprite
	if direction_x > 0:
		sprite.flip_h = false
		pickup_area.position.x = pickup_offset
		pickup_area.position.y = 0
	elif direction_x < 0:
		sprite.flip_h = true
		pickup_area.position.x = -pickup_offset
		pickup_area.position.y = 0
	if direction_y > 0:
		pickup_area.position.y = pickup_offset
		pickup_area.position.x = 0
	elif direction_y < 0:
		pickup_area.position.y = - pickup_offset
		pickup_area.position.x = 0
	
	velocity = velocity.normalized() * SPEED
	move_and_slide()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SPACE:
			pickup_item()

func pickup_item():
	if facing_item != null:
		PlayerInventory.unique_items.append(facing_item.item_name)
		print(facing_item.item_name)
		facing_item.queue_free()

func _on_pickup_area_body_entered(body):
	if body.is_in_group("Item"):
		facing_item = body
		print("facing")

func _on_pickup_area_body_exited(body):
	if body.is_in_group("Item"):
		facing_item = null
