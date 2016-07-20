# ==== Pepper & Carrot Game ====
#
# Purpose: Manages game state and configuration files
#
# ==============================

extends Node

var current_scene = null
var stored_scene = null

const INPUT_ACTIONS = ["ui_accept", "jump", "up", "down", "left", "right"]

var player = null

# Display
var width = 1280 # Display width
var height = 720 # Display height
var fullscreen = false # Whether we run in fullscreen or not


# Audio
var music = true # Should the music play
var music_volume = 1 # Volume of the music, between 0 and 1
var sfx = true # Should sound effects play
var sfx_volume = 1 # Volume of sound effects, between 0 and 1


var battle_info = load("res://Scripts/battle_info.gd")

const settings_filename = "user://config.cfg"
var PLAYER_SCENE = preload("res://Scenes/Player/player.tscn")
var DEBUG = null

func _ready():
	
	DEBUG = OS.is_debug_build()
	current_scene = get_tree().get_current_scene()
	# This avoids the singleton from loading the menu scene on load when loading in debug mode, but it allows
	# loading the menu scene if the scene currently being loaded is the base scene (which should be the default)
	if DEBUG and get_tree().get_current_scene().get_filename() == "res://Scenes/base_scene.xscn":
		change_scene("res://Scenes/main_menu.xscn")
	elif DEBUG:
		change_scene(get_tree().get_current_scene().get_filename())
		
	# Load parameters from the config file, overriding the default ones
	load_config()
	
	# Handle display
	OS.set_window_size(Vector2(width, height))
	OS.set_window_fullscreen(fullscreen)
	
	# Save window size if changed by the user
	get_tree().connect("screen_resized", self, "save_screen_size")
	
func change_scene_door(path, door_number):
	change_scene(path, false)
	spawn_player(door_number)

func spawn_player(door_number=-1):
	"""var doors = get_tree().get_nodes_in_group("doors")
	if door_number != -1:
		for door in doors:
			if door.door_number == door_number:
				var player_instance = PLAYER_SCENE.instance()
				get_tree().get_current_scene().add_child(player_instance)
				player_instance.set_pos(door.get_pos())
				print("Player spawned on door: " + str(door_number))
				return
	
	var player_spawn = get_tree().get_nodes_in_group("player_start")
	if player_spawn.size() > 0:
		var player_instance = PLAYER_SCENE.instance()
		get_tree().get_current_scene().add_child(player_instance)
		player_instance.set_pos(player_spawn[0].get_pos())
		print("Player spawned")"""
	pass
func change_scene(path, cached = false):
	# Make sure there's no scene code running to avoid crashes
	call_deferred("change_scene_impl", path, cached)
	
func change_to_cached_scene():
	# Make sure there's no scene code running to avoid crashes
	call_deferred("change_to_cached_scene_impl")

func set_player(new_player):
	print(new_player)
	player=new_player

func get_player():
	return player;

# Actual implementation of change_scene
func change_scene_impl(path, cached = false):
	var tree_root = get_tree().get_root()
	# This is for caching scenes only
	if(cached == true and current_scene):
		# Pack the scene state in a resource
		var packed_scene = PackedScene.new()
		packed_scene.pack(current_scene)
		stored_scene = packed_scene
		current_scene.free()
		
	elif(current_scene):
		current_scene.free()
	var scene = ResourceLoader.load(path)
	current_scene = scene.instance()
	tree_root.add_child(current_scene)
	
	print("Loaded scene: ", path)
	print("Caching last scene: ", cached)
	#spawn_player(0)


func change_to_cached_scene_impl():
	var tree_root = get_tree().get_root()
	if(current_scene and stored_scene):
		current_scene.free()
		#Create an instance from the packed scene
		current_scene = stored_scene.instance()
		stored_scene = null
		
		tree_root.add_child(current_scene)
		

func load_config():
	"""Load the user-defined settings from the default settings file. Create this file
	if it is missing and populate it with default values as defined in this class.
	"""
	var config = ConfigFile.new()
	var err = config.load(settings_filename)
	if err:
		# Config file does not exist, dump default settings in it
		
		# Are any other forms of error handling needed here? if the
		# config file is invalid it just gets overriden with default
		# values
		
		# Display
		config.set_value("display", "width", width)
		config.set_value("display", "height", height)
		config.set_value("display", "fullscreen", fullscreen)
		
		# Audio
		config.set_value("audio", "music", music)
		config.set_value("audio", "music_volume", music_volume)
		config.set_value("audio", "sfx", sfx)
		config.set_value("audio", "sfx_volume", sfx_volume)
		
		# Default inputs
		var action_name
		for i in range(1, 5):
			for action_name in INPUT_ACTIONS:
				config.set_value("input", action_name, OS.get_scancode_string(InputMap.get_action_list(action_name)[0].scancode))
		
		config.save(settings_filename)
	else:
		# Display
		set_from_cfg(config, "display", "width")
		set_from_cfg(config, "display", "height")
		set_from_cfg(config, "display", "fullscreen")
		
		# Audio
		set_from_cfg(config, "audio", "music")
		set_from_cfg(config, "audio", "music_volume")
		set_from_cfg(config, "audio", "sfx")
		set_from_cfg(config, "audio", "sfx_volume")
		
		# Input overrides
		var scancode
		var event
		for action in config.get_section_keys("input"):
			# Get the key scancode corresponding to the saved human-readable string
			scancode = OS.find_scancode_from_string(config.get_value("input", action))
			# Create a new event object based on the saved scancode
			event = InputEvent()
			event.type = InputEvent.KEY
			event.scancode = scancode
			# Replace old actions by the new one - apparently erasing the old action
			# works better to get the control buttons properly initialised in the UI
			# TODO: Handle multiple events per action in a better way
			for old_event in InputMap.get_action_list(action):
				if old_event.type != InputEvent.JOYSTICK_BUTTON:
					InputMap.action_erase_event(action, old_event)
			InputMap.action_add_event(action, event)
			
func set_from_cfg(config, section, key):
	"""Retrieve the parameter from the config file, or restore it
	if it is missing from the config file.
	"""
	if config.has_section_key(section, key):
		set(key, config.get_value(section, key))
	else:
		print("Warning: '" + key + "' missing from '" + section + "' section in the config file, default value has been added.")
		save_to_config(section, key, get(key))

func save_to_config(section, key, value):
	var config = ConfigFile.new()
	var error = config.load(settings_filename)
	if error:
		# TODO: Better error handling
		print("Error loading config: ", error)
	else:
		config.set_value(section, key, value)
		config.save(settings_filename)

func save_screen_size():
	"""
	var screen_size = OS.get_window_size()
	width = int(screen_size.x)
	height = int(screen_size.y)
	save_to_config("display", "width", width)
	save_to_config("display", "height", height)
	"""
	# TODO: FIX THIS
	pass
	
class PlayerTeam:
	var characters = {}
	var selected_characters = {"1": null, "2": null}
	func load_defaults():
		characters.append(battle_info.CharacterInfo.load_from_file("pepper"))