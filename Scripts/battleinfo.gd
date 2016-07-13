# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: Set of classes to hold battle character stats
#
# ==============================

class CharacterInfo:
	var vitality = 0.0
	var power = 0.0
	var intelligence = 0.0
	var pet_bond = 0.0
	var speed = 0.0
	func _init(_vitality, _power, _intelligence, _pet_bond, _speed):
		vitality = _vitality
		power = _power
		intelligence = _intelligence
		pet_bond = _pet_bond
		speed = _speed
		
#	static func get_default_character_info(name):
#		if name == "pepper":
#			return CharacterInfo.new(

class Stat:
	var name = "stat"
	var stat_multiplier = 0
	var raw_value = 0
	const CONSTANT_V = 1638400
	func _init(_name,_stat_multiplier, _level_growth, _raw_value):
		name = _name
		stat_multiplier = _stat_multiplier
		level_growth = _level_growth
		raw_value = _raw_value
	func level_up(new_level):
		raw_value = (raw_value*stat_multiplier)/CONSTANT_V
	func get_stat_public_value():
		# Returns the stat value for the user
		return (raw_value*stat_multiplier)/CONSTANT_V