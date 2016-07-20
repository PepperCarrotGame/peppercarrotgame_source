# ==== Pepper & Carrot Game ====
#
# Purpose: Manages the character itself and it's battle flow.
#
# ==============================
extends Node2D

var battle_manager

var state

var new_state

var execute_state
var wait_state

var character_info

# Visible character

func _init(n_character_info, n_battle_manager):
	character_info = n_character_info
	# Default state initialization
	wait_state = WaitingState
	execute_state = ExecuteState
	
	battle_manager = n_battle_manager

func _ready():
	add_to_group("characters")
	new_state = WaitingState.new(self)
	
func Update(delta):
	# State change
	if new_state != state:
		state.OnExit()
		state = new_state
		state.OnEnter()
	state.Update(delta)
	
func receive_damage(damage):
	pass

class CharacterBattleState:
	var battle_state
	
	func _init_(e_battle_state):
		battle_state = e_battle_state
		pass

# BATTLE STATES

class WaitingState:
	extends CharacterBattleState
	var waiting_delta = 0 
	var waiting_time

	func Update(delta):
		waiting_delta = waiting_delta + delta
		if waiting_delta >= waiting_time:
			new_state = battle_state.execute_state.new(battle_state)
			pass
	func OnExit():
		pass
	func OnEnter():
		waiting_time = e_waiting_time

class ExecuteState:
	extends CharacterBattleState
	func OnEnter():
		var attack = battle_manager.get_attack_for_character()
		attack.do_attack()
	
	func _init(e_battle_state):

		pass