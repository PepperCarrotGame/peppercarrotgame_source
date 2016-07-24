extends Node

var character_info = load("res://Scripts/character_info.gd")
var battle_script = load("res://Scripts/Battle/battle.gd")
	
# Actual implementation of change_scene
func start_battle():
	

	
	var game_manager = get_node("/root/game_manager")
	game_manager.change_scene("res://Scenes/Battle/battle.tscn", false, self, "start_battle_callback")
	#spawn_player(0)
	
func start_battle_callback(current_scene):
	var charinfo = character_info.CharacterInfo.new()
	charinfo.load_from_file("wolf")

	var entity = battle_script.BattleEntity.new()
	entity.character_info = charinfo
	entity.player_controlled = false
	entity.position = 0
	
	current_scene._start_battle([entity])
	pass