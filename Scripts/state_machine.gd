# ==== Pepper & Carrot Game ====
#
# Purpose: Unified state machine
#
# ==============================
extends Node

var states = {}
var current_state = null

func add_state(state):
	states[state.name] = state

func _ready():
	set_process(true)

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

class State:
	extends Node
	var state_machine
	func _init(state_machine):
		self.state_machine = state_machine
	func OnEnter():
		pass
	func OnExit():
		pass
	func Update():
		pass
	func Input():
		pass