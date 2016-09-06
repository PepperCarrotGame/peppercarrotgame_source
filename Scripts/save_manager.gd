
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
# Loads a game's info, without loading a map.
func load_game(filename):
	load_game_no_map(filename)
func load_game_no_map(filename):
	var file = File.new()
	file.open("user://" + filename + ".fsav", File.READ)
	# Parse from file
	var file_contents = ""
	var final_dict = {}
	while(!file.eof_reached()):
		file_contents = file_contents + file.get_line()
	final_dict.parse_json(file_contents)
	var player_data_dict = final_dict["player_data"]
	
	# Parse it and put it in the GameManager's character_info property.
	var game_manager = get_node("/root/game_manager")
	var final_player_data = game_manager.PlayerData.get_full_player_data_from_dict(player_data_dict)
	game_manager.player_data = final_player_data
	print("strong")