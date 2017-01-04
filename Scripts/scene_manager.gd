extends Node

## CONST: The scene that should be spawned and that the player directly controls
const PLAYER_SCENE = preload("res://Scenes/Player/player.tscn")

var _game_manager
var current_scene = null
var current_scene_path
## Contains the player object in the world, should not be accessed directly, use get_player() instead.
var player
## Scene loading
var _loading_screen = preload("res://Scenes/UI/loading_screen.tscn").instance()
## Scene that is being loaded
var _scene_being_loaded

var _current_scene_no_free = false
var _current_scene_camera_spawn = false
var _current_scene_callback_object
var _current_scene_callback_method
var _is_loading_scene = false

func _ready():
	_game_manager = get_node("/root/game_manager")
	set_process(true)
func _process(delta):
	if _is_loading_scene:
		_check_scene_load_progress()
		
		
func _check_scene_load_progress():
	if _game_manager.resource_queue.is_ready(_scene_being_loaded):
		var tree_root = get_tree().get_root()
			
		if current_scene:
			if not _current_scene_no_free:
				current_scene.free()
		var scene_resource = _game_manager.resource_queue.get_resource(_scene_being_loaded)
		current_scene = scene_resource.instance()
		current_scene_path = _scene_being_loaded
		tree_root.add_child(current_scene)
		
		print("Loaded scene: ", _scene_being_loaded)
		
		if _current_scene_callback_object:
			_current_scene_callback_object.call(_current_scene_callback_method, current_scene)
		
		call_deferred("spawn_player",_current_scene_camera_spawn)
		
		_is_loading_scene = false
		

		
## Spawns the player
# @param door_number The door number to spawn the player at, -1 if the player should be spawned at default spawn point, defaults to -1
# @param camera_spawn - If the camera should be set to aim at the menu_camera object and disable input to the character, defaults to false.
func spawn_player(camera_spawn=false):
	#var doors = get_tree().get_nodes_in_group("doors")
	"""if door_number != -1:
		for door in doors:
			if door.door_number == door_number:
				var player_instance = PLAYER_SCENE.instance()
				get_tree().get_current_scene().add_child(player_instance)
				player_instance.set_global_pos(door.get_global_pos())

				print("Player spawned on door: " + str(door_number))
				return"""
	var player_spawn = get_tree().get_nodes_in_group("player_start")
	if player_spawn.size() > 0:
		var player_instance = PLAYER_SCENE.instance()
		player_instance.set_pos(player_spawn[0].get_pos())
		if camera_spawn:
			var camera_start = get_tree().get_nodes_in_group("menu_camera")[0]
			player_instance.get_camera().set_offset(camera_start.get_pos() - player_instance.get_pos())
			player_instance.disable_input(true)
		print(camera_spawn)
		current_scene.add_child(player_instance)
		print("Spawned player")
	else:
		print("Found no Spawn object node in current scene.")
		
## Changes the scene
# @param path New scene path.
# @param callback_object Object to callback to when loading is done.
# @param callback Callback method on object to callback.
# @param no_free if set to true the previous scene will not be freed from memory.
# @param camera_spawn if set to true, camera_spawn is passed as true to  spawn_player()
func change_scene(path, callback_object=null ,callback = null, no_free = false, camera_spawn = false):
	# Make sure there's no scene code running to avoid crashes
	call_deferred("change_scene_impl", path, callback_object, callback, no_free, camera_spawn)
	
## Sets the player node to a new one.
func set_player(new_player):
	player=new_player

## Gets the player node.
# @return The player object.
func get_player():
	return player

# Actual implementation of change_scene
func change_scene_impl(path, callback_object=null, callback = null, no_free = false, camera_spawn=false):
	_scene_being_loaded = path
	_game_manager.resource_queue.queue_resource(path)
	_is_loading_scene = true
	_current_scene_no_free = no_free
	_current_scene_camera_spawn = camera_spawn
	_current_scene_callback_object = callback_object
	_current_scene_callback_method = callback
	
## Changes the scene but with a loading screen
# @param path New scene path.
func change_scene_load_screen(path, no_free = false, camera_spawn=false):
	#var game_manager = get_node("/root/game_manager")
	_game_manager.ui_layer.add_child(_loading_screen)
	call_deferred("change_scene_impl", path, self, "_load_screen_callback", no_free, camera_spawn)
	
func _load_screen_callback(current_scene=null):
	_game_manager.ui_layer.remove_child(_loading_screen)
	pass