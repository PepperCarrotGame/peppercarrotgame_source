# ==== Pepper & Carrot Game ====
#
# Purpose: Manages game state
#
# ==============================

extends Node

var current_scene = null
var stored_scene = null

var DEBUG = null

func _ready():
	DEBUG = OS.is_debug_build()
	change_scene("res://Scenes/main_menu.xscn")
	

func change_scene(path, cached = false):
	# Make sure there's no scene code running to avoid crashes
	call_deferred("change_scene_impl", path, cached)
	
func change_to_cached_scene():
	# Make sure there's no scene code running to avoid crashes
	call_deferred("change_to_cached_scene_impl")
	
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
	if(DEBUG):
		print("Loaded scene: ", path)
		print("Caching last scene: ", cached)
		
func change_to_cached_scene_impl():
	var tree_root = get_tree().get_root()
	if(current_scene and stored_scene):
		current_scene.free()
		#Create an instance from the packed scene
		current_scene = stored_scene.instance()
		stored_scene.free()
		tree_root.add_child(current_scene)