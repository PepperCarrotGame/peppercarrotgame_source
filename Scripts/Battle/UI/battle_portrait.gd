tool
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

export (bool) var show_triangle = true

var battle_entity

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass
func _process(delta):
	if show_triangle:
		get_node("triangle").set_hidden(false)
	else:
		get_node("triangle").set_hidden(true)
