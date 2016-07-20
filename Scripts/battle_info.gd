# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: Set of classes to hold battle character stats
#
# ==============================
class Stat:
	var name = "stat"
	var stat_multiplier = 0.0
	var raw_value = 0.0
	var level_growth = 0.0
	const CONSTANT_V = 1638400.0
	func _init(_name,_stat_multiplier, _level_growth, _raw_value):
		name = _name
		stat_multiplier = _stat_multiplier
		level_growth = _level_growth
		raw_value = _raw_value
	func level_up(old_level):
		raw_value = raw_value + (raw_value/(level_growth+old_level))
	func get_public_value():
		# Returns the stat value for the user
		return ceil((raw_value*stat_multiplier)/CONSTANT_V)

class CharacterInfo:
	var stats = {}
	var attacks = {}
	var level
	var name
	var internal_name
	var player_controlled = false
	var HP = 0
	var MP = 0
	func _init(_vitality, _power, _intelligence, _pet_bond, _speed):
		stats["vitality"] = _vitality
		stats["power"] = _power
		stats["intelligence"] = _intelligence
		stats["pet_bond"] = _pet_bond
		stats["speed"] = _speed
	func level_up():
		# Makes all stats level up
		for stat_name in stats:
			var stat = stats[stat_name]
			stat.level_up(level)
			HP = stats["vitality"].get_public_value()
			MP = stats["intelligence"].get_public_value()
			level = level+1
	static func load_from_file(character_name):
		var path = "res://Stats/" + character_name + ".json"
		print(path)
		var file_contents = ""
		var final_dict = {}
		var file = File.new()
		file.open(path, File.READ)
		if !file.file_exists(path):
			return
		
		while(!file.eof_reached()):
			file_contents = file_contents + file.get_line()
		print(file_contents)
		final_dict.parse_json(file_contents)
		
		# Base info parsing
		level = final_dict["level"]
		name = final_dict["name"]
		internal_name = final_dict["internal_name"]
		player_controlled = final_dict["player_controlled"]
		# Stats parsing
		stats_dict = final_dict["stats"]
		var stats = {}
		for key in stats_dict:
			var stat = stats_dict[key]
			stats[key] = Stat.new(key, stat["stat_multiplier"], stat["level_growth"],stat["raw_value"])
		var attacks_dict = final_dict["attacks"]
		for key in attacks_dict:
			var attack = attacks_dict[key]
			attacks[key] = Attack.new(attack["name"], attack["internal_name"], attack["attack_modifier"], attack["animation_name"])

class Attack:
	var name
	var internal_name
	var attack_modifier
	var animation_name
	func _init(_name, _internal_name, _attack_modifier, _animation_name):
		name = _name
		internal_name = _internal_name
		attack_modifier = _attack_modifier
		animation_name = _animation_name