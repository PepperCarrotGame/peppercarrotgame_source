
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass




func _on_Button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.change_to_cached_scene()
	pass # replace with function body