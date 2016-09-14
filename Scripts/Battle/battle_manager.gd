extends Node

var character_info = load("res://Scripts/character_info.gd")
var battle_script = load("res://Scripts/Battle/battle.gd")
	
func start_battle(battle_set):
	#var main_enemy = battle_script.BattleEntity.new()
	#main_enemy.character_info = base_enemy
	
	var game_manager = get_node("/root/game_manager")
	game_manager.change_scene("res://Scenes/Battle/battle.tscn")
	call_deferred("start_battle_callback", battle_set)
	
func start_battle_callback(battle_set):
	print("callback")
	var game_manager = get_node("/root/game_manager")
	game_manager.current_scene.start_battle(battle_set)