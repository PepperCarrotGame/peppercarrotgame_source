# ==== Pepper & Carrot Game ====
#
# Purpose: This code performs rebinding of buttons
#
# ==============================


extends MenuButton

# member variables here, example:
# var a=2
# var b="textvar"

var action = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_action(action_name):
	# First input should always be keyboard, but just in case
	var input_event
	for event in InputMap.get_action_list(action_name):
		if event.type == InputEvent.KEY:
			input_event = event
			break
	if(input_event.type == InputEvent.KEY):
		if(input_event != null):
			action = action_name
			# TODO: make this pretty
			set_text(OS.get_scancode_string(input_event.scancode) + " " +tr("input_" + action))
			
func bind_signal(name, target, callback):
	connect(name, target, callback)