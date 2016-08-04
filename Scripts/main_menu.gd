# ==== Pepper & Carrot Game ====
#
# Purpose: Code for the main menu
#
# ==============================

extends Node2D

func _ready():
	get_node("CanvasLayer/ButtonContainer/play_button").grab_focus()
	pass

# This disables the game's debugging features, but does not disable the engine's
func _on_disable_debug_button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.DEBUG = false
	print("Disabling custom debugging features")


func _on_options_button_pressed():
	game_manager.change_scene("res://Scenes/UI/keybindings.tscn", true)


func _on_exit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed():
	game_manager.change_scene("res://Scenes/test_scene.xscn")
	pass # replace with function body
