# ==== Pepper & Carrot Game ====
## @package options_menu
# Code for the options menu
#
# ==============================

extends Container

## Buttons that are allowed by the options menu rebinder, by default it only allows game_manager.INPUT_ACTIONS
var allowed_actions = game_manager.INPUT_ACTIONS

## The button
var button = null
func _ready():
	
	get_node(".").connect("resized",self,"_resized")
	
	set_process(true)
	
	for action in allowed_actions:
		var button_scene = ResourceLoader.load("res://Scenes/UI/keybind_button.tscn")
		button_scene = button_scene.instance()
		get_node("ScrollContainer/ButtonContainer").add_child(button_scene)
		button_scene.set_action(action)
		button = button_scene
		button_scene.bind_signal("pressed",self,"wait_for_input")

func _process(delta):
	var button_container = get_node("ScrollContainer/ButtonContainer")
	var parent_size = Vector2(get_node("ScrollContainer").get_size().x, button_container.get_size().y)
	button_container.set_size(parent_size)

## Returns to the main menu.
# TODO: Fix this.
func _on_back_button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.change_to_cached_scene()
	pass

## Enables set_process_input
func wait_for_input():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		# Got a valid input, stop polling and reinitialise context help
		set_process_input(false)
		# Unless the input is a cancel key, display the typed key and change the binding
		if not event.is_action("ui_cancel"):

			change_key(button.action, event)

## Changes the key to a new one
func change_key(action, event):
	# Clean all previous bindings
	
	for old_event in InputMap.get_action_list(action):
		#But don't remove gamepad bindings
		if old_event.type != InputEvent.JOYSTICK_BUTTON:
			InputMap.action_erase_event(action, old_event)
	# Bind the new event to the chosen action
	InputMap.action_add_event(action, event)
	# Save the human-readable string in the config file
	game_manager.save_to_config("input", action, OS.get_scancode_string(event.scancode))
	button.set_action(button.action)