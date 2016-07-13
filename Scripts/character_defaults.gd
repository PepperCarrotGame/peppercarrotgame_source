# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: Contains the default character stats
#
# ==============================

func get_character_defaults(character):
	var stats = {}
	var battle_info = load("res://Scripts/battle_info.gd")
	var stat = battle_info.Stat
	
	if character == "pepper":
	#func _init(_name,_stat_multiplier, _level_growth, _raw_value):
		stats["vitality"] = stat.new("vitality", 200.0, 10.0, 400000.0)
		stats["power"] = stat.new("power", 420.0, 2.0, 300000.0)
		stats["intelligence"] = stat.new("intelligence", 450.0, 6.0, 380000.0)
		stats["pet_bond"] = stat.new("pet_bond", 250.0, 7.0, 500000.0)
		stats["speed"] = stat.new("speed", 75.0, 7.0, 500000.0)
		
	var character_info = battle_info.CharacterInfo.new(0,0,0,0,0)
	character_info.stats = stats
	return character_info