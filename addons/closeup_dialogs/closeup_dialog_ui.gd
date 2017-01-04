
extends Node2D

## All dialogs to play, ordered.
var _dialog_nodes = []

## Current dialog node we are playing
var _current_dialog

## Time since dialog started playing
var _counter = 0

## Character sprite scenes
var _character_scenes

## Wether or not text should be playing
var _is_playing = false

## Current text as it's being printed
var _current_text = ""

var _dialog_node_index = 0

var _current_sprite
var _last_sprite
var _last_dialog
var _dialog_controller

var _waiting_for_startup_animation_to_end = true

var _game_manager

func _ready():
	get_node("UI").set_hidden(true)
	get_tree().set_pause(true)
	_game_manager = get_node("/root/game_manager")
	
## Starts playing a full dialog from a dialog controller
# @param dialog_controller The dialog controller.
func start_dialog(dialog_controller):
	get_tree().set_pause(true)
	var game_manager = get_node("/root/game_manager")
	_dialog_nodes = dialog_controller._dialog_nodes
	_character_scenes = dialog_controller._character_sprites
	get_node("UI").set_hidden(true)
	get_node("AnimationPlayer").connect("finished", self, "_animation_finished")
	get_node("AnimationPlayer").play("DialogStartup")
	_dialog_controller = dialog_controller
	_game_manager.state_machine.current_state.disable_pause(true)
func _animation_finished():
	if get_node("AnimationPlayer").get_current_animation() == "DialogStartup":
		_play_dialog_node(_dialog_nodes[0])
		set_process(true)
		set_process_input(true)
## Starts playing a node
func _play_dialog_node(dialog):
	_counter = 0
	_last_dialog = _current_dialog
	_current_dialog = dialog
	_current_text = ""
	_is_playing = true
	if _last_dialog:
		# If the character is not the same but it's on the same side we should free it
		if _last_dialog.position == _current_dialog.position:
			if _last_dialog.character != _current_dialog.character:
				remove_child(_current_sprite)
		else:
			_last_sprite = _current_sprite
			_last_sprite.set_opacity(0.5)
	_current_sprite = _character_scenes[_current_dialog.character]
	_current_sprite.set_opacity(1)
	if _current_dialog.position == "Left":
		_current_sprite.set_pos(get_node("UI/PlaceHolderLeft").get_pos())
		_current_sprite.set_flip_h(false)
	else:
		_current_sprite.set_pos(get_node("UI/PlaceHolderRight").get_pos())
		_current_sprite.set_flip_h(true)
	get_node("UI").add_child(_current_sprite)
	get_node("UI").set_hidden(false)
	set_process(true)
func _process(delta):
	if _is_playing:
		var speed = get_node("/root/game_manager").text_speed
		_counter += delta
		var _current_text_pos = int(_counter*speed)
		_current_text = "[center]" + _current_dialog.text.substr(0,_current_text_pos) + "[/center]"
		_update_ui()
		if _current_text_pos >= tr(_current_dialog.text).length():
			_finish_node_play()

func _finish_node_play():
	_is_playing = false
	_current_text = "[center]" + _current_dialog.text + "[/center]"
	_dialog_node_index += 1
	set_process(false)
	_update_ui()

func _input(event):
	if event.is_action("jump") and not event.is_echo() and event.is_pressed():
		if _is_playing:
			_finish_node_play()
		else:
			if _dialog_nodes.size() >= _dialog_node_index+1:
				_play_dialog_node(_dialog_nodes[_dialog_node_index])
			elif _dialog_controller.unpause_after:
				get_tree().set_input_as_handled()
				
				_game_manager.state_machine.current_state.disable_pause(false)
				set_hidden(true)
				get_node("UI").remove_child(_current_sprite)
				get_node("UI").remove_child(_last_sprite)
				_dialog_node_index = 0
				set_process_input(false)
				get_tree().call_deferred("set_pause", false)
func _update_ui():
	get_node("UI/CharacterName").set_text(tr(_current_dialog.character_information.name))
	get_node("UI/Panel/Text").set_bbcode(_current_text)