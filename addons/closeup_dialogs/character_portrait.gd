
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func set_flip_h(flip_h):
	get_node("Sprite").set_flip_h(flip_h)