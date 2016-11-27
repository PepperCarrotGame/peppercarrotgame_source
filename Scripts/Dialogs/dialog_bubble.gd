# ==== Pepper & Carrot Game ====
#
# Purpose: Display the character's dialog text
#
# ==============================

extends Node2D

# Text speed in chars per second
export var speed = 10
# export var character_name = "Put character name here"
export(bool) var thinking = false 
export(bool) var right_character = false 
export(String, MULTILINE) var animated_text = "Put animated text here."
export(NodePath) var next_dialog
export(NodePath) var action
export(bool)var should_fade_in = false
export(bool)var should_fade_out = false 


var counter = 0
var finished = false
var button_pressed = false
var button_released = false

func start():
	set_hidden(false)
	if should_fade_in:
		set_opacity(0)
		get_node("AnimationPlayer").play("fade_in")
	else:
		set_opacity(1)
	set_process(true)

func _ready():
	# set_process(true)
	
	# Load character name
	# get_node("Character Name").set_text(str(character_name, ":"))
	
	# If thinking hide talking and show thinking
	if (thinking):
		get_node("Spike/talking").set_hidden(true)
		get_node("Spike/thinking").set_hidden(false)
		
	# If character is on the right side flip the spike
	if (right_character):
		get_node("Spike").set_scale(Vector2(-1, 1))


func _process(delta):
	check_button()
	
	if !finished:
		if button_released:
			finish_animation()
		else:
			animate_text(delta)
	else:
		if button_released:
			close_dialog()


func check_button():
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


func finish_animation():
	get_node("Text").set_text(animated_text)
	finished = true
func animate_text(delta):
	counter += delta
	var characters = int(counter*speed)
	
	get_node("Text").set_text(animated_text.substr(0, characters));
	if (characters > animated_text.length()):
		finished = true
		if should_fade_out:
			get_node("AnimationPlayer").play("fade_out")
		# close_dialog()


func close_dialog():
	set_process(false)
	set_hidden(true)
	if (next_dialog):
		var node = get_node(next_dialog)
		if (node.has_method("start")):
			node.start()
	
	if (action):
		var node = get_node(action)
		if (node.has_method("start")):
			node.start()
	