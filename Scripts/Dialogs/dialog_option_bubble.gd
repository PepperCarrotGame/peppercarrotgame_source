# ==== Pepper & Carrot Game ====
#
# Purpose: Display the character's options
#
# ==============================

extends Node2D

# Exportable vars
export(int, 1, 4) var options = 4
export(String) var option1_text = "Option 1 text."
export(NodePath) var option1_action
export(String) var option2_text = "Option 2 text."
export(NodePath) var option2_action
export(String) var option3_text = "Option 3 text."
export(NodePath) var option3_action
export(String) var option4_text = "Option 4 text."
export(NodePath) var option4_action

var activeOption = 1

# Button vars
var button_pressed = false
var button_released = false
var up_pressed = false
var up_released = false
var down_pressed = false
var down_released = false

func start():
	set_hidden(false)
	set_process(true)

func _ready():
	# set_process(true)
	
	# Load options texts
	get_node("option_1/text").set_text(option1_text)
	get_node("option_2/text").set_text(option2_text)
	get_node("option_3/text").set_text(option3_text)
	get_node("option_4/text").set_text(option4_text)
	
	# Disable unused options
	if options < 4:
		for i in range(options+1, 5):
			get_node("option_" + str(i)).set_hidden(true)

func _process(delta):
	check_buttons()
	
	if up_released:
		change_selected_option(-1)
		
	if down_released:
		change_selected_option(1)
	
	if button_released:
		close_dialog()

func change_selected_option(increment):
	print("change_selected_option. increment: " + str(increment))
	activeOption += increment
	
	if activeOption < 1:
		activeOption = 1
	elif activeOption > options:
		activeOption = options
		
	print("change_selected_option. activeOption: " + str(activeOption))
		
	# Disable unchecked options
	for i in range(1, options+1):
		get_node("option_" + str(i) + "/select").set_hidden(i != activeOption)

func check_buttons():
	check_up()
	check_down()
	check_jump()

func check_jump():
	var button = Input.is_action_pressed("jump")
	
	# Button pressed for first time
	if !button_pressed && button:
		# print("button Pressed for first time")
		button_pressed = true
		button_released = false
	# Button pressed and released
	elif button_pressed && !button:
		# print("button Released for first time")
		button_released = true
		button_pressed = false
	# If button released previously reset vars
	elif button_released:
		# print("button Released, reset vars")
		button_pressed = false
		button_released = false


func check_up():
	var upButton = Input.is_action_pressed("up")
	
	# Button pressed for first time
	if !up_pressed && upButton:
		# print("button Pressed for first time")
		up_pressed = true
		up_released = false
	# Button pressed and released
	elif up_pressed && !upButton:
		# print("button Released for first time")
		up_released = true
		up_pressed = false
	# If button released previously reset vars
	elif up_released:
		# print("button Released, reset vars")
		up_pressed = false
		up_released = false


func check_down():
	var downButton = Input.is_action_pressed("down")
	
	# Button pressed for first time
	if !down_pressed && downButton:
		# print("button Pressed for first time")
		down_pressed = true
		down_released = false
	# Button pressed and released
	elif down_pressed && !downButton:
		# print("button Released for first time")
		down_released = true
		down_pressed = false
	# If button released previously reset vars
	elif down_released:
		# print("button Released, reset vars")
		down_pressed = false
		down_released = false


func close_dialog():
	print("close_dialog. activeOption: " + str(activeOption))
	set_process(false)
	
	# Get the selected action
	var action
	if activeOption == 1:
		action = option1_action
	elif activeOption == 2:
		action = option2_action
	elif activeOption == 3:
		action = option3_action
	elif activeOption == 4:
		action = option4_action
	print("change_selected_option. action: " + str(action))
	
	if (action):
		var node = get_node(action)
		print("change_selected_option. node: " + str(node))
		if (node.has_method("start")):
			print("Tiene método start")
			node.start()
	
	set_hidden(true)