# ==== Pepper & Carrot Game ====
#
## @package game_states 
# AKA gamemodes, they manage global stuff like the pause UI.
#
# ==============================

var state_machine = preload("res://Scripts/state_machine.gd")

## Base game state, should not be used.
class GameState:
	extends "res://Scripts/state_machine.gd".State
	func Update(delta):
		pass
	func OnEnter():
		pass
	func _init(state_machine).(state_machine):
		pass
## State that manages the game when ingame
class InGameState:
	extends GameState
	
	var pause_enabled = true
	var pause_menu_scene = preload("res://Scenes/UI/pause_menu.tscn")
	## Current pause menu node.
	var pause_menu
	
	var _pre_pause_state
	var _is_pause_menu_open
	
	## State name (for the debugger)
	const name = "ingame"
	
	## If the player can pause or no.
	var can_pause = true
	func OnEnter():
		#PAUSE_MODE_PROCESS
		var game_manager = get_node("/root/game_manager")
		pause_menu = pause_menu_scene.instance()
		pause_menu.set_hidden(true)
		game_manager.ui_layer.add_child(pause_menu)
		set_pause_mode(2)
	func _init(state_machine).(state_machine):
		pass
	func _ready():
		  set_process_unhandled_input(true)
	func _unhandled_input(event):
		if pause_enabled:
			# To avoid issues we always store the pause state before pausing.
			if event.is_action("pause") && event.is_pressed() && !event.is_echo():
				get_tree().set_input_as_handled()
				if _is_pause_menu_open:
					get_tree().set_pause(_pre_pause_state)
					pause_menu.set_hidden(true)
					_is_pause_menu_open = false
					print("UnPaused")
				else:
					_pre_pause_state = get_tree().is_paused()
					get_tree().set_pause(true)
					pause_menu.set_hidden(false)
					pause_menu.get_controller_focus()
					_is_pause_menu_open = true
					print("Paused")
				get_tree().set_input_as_handled()
			
	func disable_pause(disable):
		pause_enabled = !disable