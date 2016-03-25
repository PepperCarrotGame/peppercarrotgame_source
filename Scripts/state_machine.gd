# ==== Pepper & Carrot Game ====
#
# Purpose: Generic state machine
#
# ==============================
extends Node

var states = {}
var current_state = null

func add_state(name, state):
	if(is_valid_state(state)):
		states[name] = state
	
func _ready():
	is_processing(true)

# Checks if state contains the required methods
static func is_valid_state(state):
	if(state.has_method("on_enter") and state.has_method("update") and state.has_method("on_exit")):
		return true
	else:
		return false

func change_state(name, params):
	new_state = states[name]
	if(new_state and is_valid_state(new_state)):
		if(is_valid_state(current_state)):
			# Remove old state
			current_state.on_exit()
			
			# Set new state as current and fire events
			current_state = new_state
			current_state.on_enter()
		else:
			# This should never happen
			if(OS.is_debug_build()):
				print("Current state is invalid")
	else:
		# This can happen, but if it does we are dumb
		if(OS.is_debug_build()):
			print("State is invalid")
			
func _process(delta):
	if(is_valid_state(current_state)):
		current_state.update(delta)