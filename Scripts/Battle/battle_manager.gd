extends Node

var _scene_manager

var character_info = load("res://Scripts/character_info.gd")
var battle_script = load("res://Scripts/Battle/battle.gd")
	
var _battle_set
func start_battle(battle_set):
	_scene_manager = get_node("/root/scene_manager")
	#var main_enemy = battle_script.BattleEntity.new()
	#main_enemy.character_info = base_enemy
	
	var game_manager = get_node("/root/game_manager")
	_battle_set = battle_set
	_scene_manager.change_scene("res://Scenes/Battle/battle.tscn", self, "_start_battle_callback", null, null)
	
func _start_battle_callback(current_scene=null):
	print("callback")
	var game_manager = get_node("/root/game_manager")
	_scene_manager.current_scene.start_battle(_battle_set)