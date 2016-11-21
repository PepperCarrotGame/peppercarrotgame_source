# ==== Pepper & Carrot Game ====
#
## @package state_machine
# Unified state machine
#
# ==============================
extends Node

## States inside the SM.
var states = {}

## The state currently being used.
var current_state

## Adds a new state.
func add_state(state):
	states[state.name] = state

func _ready():
	set_process(true)

## Changes the state to a new one with params.
func change_state(name, params=null):
	var new_state = states[name].new(self)
	if current_state:
		if current_state.has_method("OnExit"):
			current_state.OnExit()
		current_state.free()

	current_state = new_state
	add_child(current_state)
	if current_state.has_method("OnEnter"):
		current_state.OnEnter()

## Generic state class.
#
# Inherits: Node
class State:
	extends Node
	## Reference to the state machine.
	var state_machine
	func _init(state_machine):
		self.state_machine = state_machine
		
	## Executed when entering the State.
	func OnEnter():
		pass
		
	## Executed when exiting the state.
	func OnExit():
		pass
		
	## Should be executed on each frame.
	#@param delta Delta time.
	func Update(delta):
		pass
	## Equivalent of _input()
	func Input():
		pass