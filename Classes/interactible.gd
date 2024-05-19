extends StaticBody2D
#class_name Interactible


@onready var facing = false
@onready var nametag = $Nametag
@onready var dialog_timer = $DialogTimer
@onready var physics_body = $PhysicsBody
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var area_2d = $Area2D
@onready var dialog_control = $DialogControl
@onready var audio = $AudioStreamPlayer2D


func _ready():
	# Remembers the scene state between fights. Could be improved later.
	if not visible:
		physics_body.disabled = true
		collision_shape_2d.disabled = true


func start_interaction():
	dialog_timer.timeout.connect(_on_dialog_timer_timeout) # Gets dc'd if scene is reloaded
	dialog_timer.start()
	dialog_control.show()
	audio.play()
	special_interaction()


func special_interaction():
	pass


# Doesn't delete from the tree, but becomes non-interactible in the game world.
func delete_me():
	hide()
	physics_body.disabled = true
	collision_shape_2d.disabled = true


func _unhandled_input(event):
	if event.is_action_pressed("accept") and facing:
		start_interaction()


func _on_area_2d_area_entered(area):
	facing = true


func _on_area_2d_area_exited(area):
	facing = false


func _on_dialog_timer_timeout():
	dialog_control.hide()

#
#func _on_visibility_changed():
	#if not visible:
		#physics_body.disabled = true
		#collision_shape_2d.disabled = true
	#else:
		#physics_body.disabled = false
		#collision_shape_2d.disabled = false
