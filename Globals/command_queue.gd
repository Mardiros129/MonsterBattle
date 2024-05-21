extends Node


@onready var command_queue : Array[Command]


func new_command_enqueue(move, user, target, speed):
	var command = Command.new()
	command.user = user
	command.target = target
	command.move = move
	command.speed = speed
	
	# Adds the command to the queue based on its speed. Highest number is first.
	if command_queue.size() == 0:
		command_queue.append(command)
	else:
		for x in command_queue.size():
			if command_queue[x].speed < command.speed:
				command_queue.insert(x, command)
			elif x == command_queue.size() - 1:
				command_queue.append(command)


func clear_command_queue():
	command_queue.clear()


class Command :
	var user
	var target
	var move
	var speed: float
