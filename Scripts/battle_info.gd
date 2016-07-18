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
	var level = 1
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
		final_dict = final_dict["stats"]
		var stats = {}
		for key in final_dict:
			var stat = final_dict[key]
			stats[key] = Stat.new(key, stat["stat_multiplier"], stat["level_growth"],stat["raw_value"])