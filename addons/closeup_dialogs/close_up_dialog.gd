# ==== Pepper & Carrot tactical RPG ====
#
## @package close_up_dialog
# Main controller for close up dialogs
#
# ==============================

tool
extends Node2D

## The first dialog in the tree
export(NodePath) var first_dialog
## The node to callback to once all text has been displayed
export (NodePath) var finish_callback_node
## Method to call in finish_callback_node once all text has been displayed.
export (String) var finish_callback_method

## If it should start playing right away.
export (bool) var autoplay = false

## Scene of the ui component of the closeup dialogs
const _UI_LAYER_SCENE = preload("closeup_dialog_ui.tscn")

## UI layer once created
var _ui_layer

## Internal list of dialog nodes
var _dialog_nodes = []
var _character_sprites = {}
var _character_sprite_paths = {}
var _resource_queue

# If we are currently loading the initial assets
var _is_loading = false

var _all_characters_loaded = false

## Recursive function that finds dialogs down a tree.
#
# @param current_dialog dialog to first search.
func find_dialogs(current_dialog):
	_dialog_nodes.append(current_dialog)
	if not current_dialog.character in _character_sprites:
		_character_sprites[current_dialog.character] = null
		_character_sprite_paths[current_dialog.character + "_path"] = current_dialog.character_information.dialog_sprite
		_resource_queue.queue_resource(current_dialog.character_information.dialog_sprite)
		
	if current_dialog.next_dialog:
		find_dialogs(current_dialog.get_next_dialog())

func _ready():

	if not get_tree().is_editor_hint():
		# Initialize the queue
		_resource_queue = preload("res://Scripts/resource_queue.gd").new()
		_resource_queue.start()
		
		# Dialog finding
		if first_dialog:
			find_dialogs(get_node(first_dialog))

		
		# Load the UI layer
		_ui_layer = _UI_LAYER_SCENE.instance()
		_is_loading = true
		set_process(true)
func _process(delta):
	_all_characters_loaded = true
	if _is_loading:
		# Load all the characters from the ResourceQueue
		for character in _character_sprites:
			var current_character_asset_path = _character_sprite_paths[character + "_path"]
			
			if _resource_queue.is_ready(current_character_asset_path):
				_character_sprites[character] = _resource_queue.get_resource(current_character_asset_path).instance()
				_character_sprites[character].set_z(-1)
				print("Loaded %s" % character)
			if not _character_sprites[character]:
				_all_characters_loaded = false
	if _all_characters_loaded:
		_is_loading = false
		if autoplay:
			get_node("/root/game_manager").ui_layer.add_child(_ui_layer)
			set_process(false)
			_ui_layer.start_dialog(self)
func dialog_done():
	# TODO
	pass
func start_dialog():
	autoplay = true