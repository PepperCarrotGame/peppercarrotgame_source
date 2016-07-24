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
	func _init(name,stat_multiplier, level_growth, raw_value):
		self.name = name
		self.stat_multiplier = stat_multiplier
		self.level_growth = level_growth
		self.raw_value = raw_value
	func level_up(old_level):
		raw_value = raw_value + (raw_value/(level_growth+old_level))
	func get_public_value():
		# Returns the stat value for the user
		return ceil((raw_value*stat_multiplier)/CONSTANT_V)
class Attack:
	var name
	var internal_name
	var attack_modifier
	var animation_name
	var execute_speed
	func _init(name, internal_name, attack_modifier, animation_name):
		name = name
		internal_name = internal_name
		attack_modifier = attack_modifier
		animation_name = animation_name
		execute_speed = execute_speed

class CharacterInfo:
	var stats = {}
	var attacks = {}
	var level
	var name
	var internal_name
	var player_controlled = false
	var HP = 0
	var MP = 0
	func _init():
		pass
	func level_up():
		# Makes all stats level up
		for stat_name in stats:
			var stat = stats[stat_name]
			stat.level_up(level)
			HP = stats["vitality"].get_public_value()
			MP = stats["intelligence"].get_public_value()
			level = level+1

	func load_from_file(character_name):
		var path = "res://Stats/" + character_name + ".json"
		var file_contents = ""
		var final_dict = {}
		var file = File.new()
		file.open(path, File.READ)
		
		if !file.file_exists(path):
			return
		
		while(!file.eof_reached()):
			file_contents = file_contents + file.get_line()
		final_dict.parse_json(file_contents)

		# Base info parsing
		level = final_dict["level"]
		name = final_dict["name"]
		internal_name = final_dict["internal_name"]
		player_controlled = final_dict["player_controlled"]
		
		# Stats parsing
		var stats_dict = final_dict["stats"]
		for key in stats_dict:
			var stat = stats_dict[key]

			stats[key] = Stat.new(key, stat["stat_multiplier"], stat["level_growth"],stat["raw_value"])
		var attacks_dict = final_dict["attacks"]
		for key in attacks_dict:
			var attack = attacks_dict[key]
			attacks[key] = Attack.new(attack["name"], attack["internal_name"], attack["attack_modifier"], attack["animation_name"])
		HP = stats["vitality"].get_public_value()
		MP = stats["intelligence"].get_public_value()