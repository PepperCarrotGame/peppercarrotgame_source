
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func save_game(filename):
	var save = File.new()
	save.open("user://" + filename + ".fsav", File.WRITE)
	var game_manager = get_node("/root/game_manager")
	var save_dict = {
		player_data = game_manager.player_data.to_dict()
	}
	save.store_line(save_dict.to_json())
	save.close()