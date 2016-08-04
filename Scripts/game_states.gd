# ==== Pepper & Carrot Game ====
#
# Purpose: Game states aka gamemodes.
#
# ==============================

var state_machine = preload("res://Scripts/state_machine.gd")

class GameState:
	extends "res://Scripts/state_machine.gd".State
	func Update(delta):
		pass
	func OnEnter():
		pass
	func _init(state_machine).(state_machine):
		pass
class InGameState:
	extends GameState
	var pause_menu_scene = preload("res://Scenes/UI/pause_menu.tscn")
	var pause_menu
	const name = "ingame"
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
		 set_process_input(true)
	func _input(event):
		var is_paused = false
		is_paused = get_tree().is_paused()
		if event.is_action("pause") && event.is_pressed() && !event.is_echo():
			if is_paused:
				get_tree().set_pause(false)
				pause_menu.set_hidden(true)
				print("UnPaused")
			else:
				get_tree().set_pause(true)
				pause_menu.set_hidden(false)
				pause_menu.get_controller_focus()
				print("Paused")
			get_tree().set_input_as_handled()