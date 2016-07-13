# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: Set of classes to hold battle character stats
#
# ==============================

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
		print("lÑ: " + str(raw_value))
	func get_public_value():
		# Returns the stat value for the user
		return ceil((raw_value*stat_multiplier)/CONSTANT_V)