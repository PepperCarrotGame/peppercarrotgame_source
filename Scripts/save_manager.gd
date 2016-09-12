# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: Manages saving the game and loading it
#
# ==============================
extends Node

var last_scene_loaded_from_save

func save_game(filename):
	var save = File.new()
	save.open("user://" + filename + ".fsav", File.WRITE)
	var game_manager = get_node("/root/game_manager")
	var save_dict = {
		player_data = game_manager.player_data.to_dict(),
		current_scene = game_manager.current_scene
	}
	save.store_line(save_dict.to_json())
	save.close()

func load_game(filename):
	load_game_no_map()
	var game_manager = get_node("/root/game_manager")
	game_manager.change_scene(last_scene_loaded_from_save)
# Loads a game's info, without loading a map.
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
	last_scene_loaded_from_save = final_dict["current_scene"]
	print("strong")