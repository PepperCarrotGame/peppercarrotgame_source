# ==== Pepper & Carrot Game ====
#
## @package main_menu
# Code for the main menu
#
# ==============================

extends Node2D

func _ready():
	get_node("CanvasLayer/ButtonContainer/play_button").grab_focus()

	call_deferred("save_check")

## Checks if anything is saved, if it is then the map is loaded as the background for the transtions.
func save_check():
	var save_manager = get_node("/root/save_manager")
	var auto_save_path = "autosave"
	var path = File.new()
	if path.file_exists("user://" + auto_save_path + ".fsav"):
		# Scene Setup
		save_manager.load_game_no_map(auto_save_path)
		
		var game_manager = get_node("/root/game_manager")
		game_manager.change_scene(save_manager.last_scene_loaded_from_save,null, null,true, true)
		call_deferred("background_setup")

## This disables the game's debugging features, but does not disable the engine's, to be used for demos maybe?
func _on_disable_debug_button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.DEBUG = false
	print("Disabling custom debugging features")

## Opens the options menu.
func _on_options_button_pressed():
	game_manager.change_scene("res://Scenes/UI/keybindings.tscn", true)

## Quits the game.
func _on_exit_button_pressed():
	get_tree().quit()

## Starts a new game.
func _on_play_button_pressed():
	game_manager.change_scene("res://Scenes/test_scene.xscn")

## Continues from the background scene.
func _on_continue_button_pressed():
	var game_manager = get_node("/root/game_manager")
	var player = game_manager.get_player()
	player.disable_input(false)
	var tree_root = get_tree().get_root()
	player.interpolate_camera_offset(Vector2(0,0))
	call_deferred("free")