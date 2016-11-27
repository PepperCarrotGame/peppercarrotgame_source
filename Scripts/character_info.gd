# ==== Pepper & Carrot tactical RPG ====
## @package character_info
# Set of classes to hold battle character stats
#
# ==============================

## Standard stat value class (health, rea etc...)
#
# Formula:
# Stat = [(raw_value * stat_multiplier)/CONSTANT_V]
class Stat:
	## Stat internal name.
	var name = "stat"
	## stat_multiplier (see formula).
	var stat_multiplier = 0.0
	## raw_value (see formula).
	var raw_value = 0.0
	## level_growth (see formula).
	var level_growth = 0.0
	## CONSTANT_V (see formula).
	const CONSTANT_V = 1638400.0
	
	## Constructor
	# @param name The stat name
	# @param stat_multiplier The stat multiplier.
	# @param level_growth The level growth.
	# @param raw_value The raw value.
	func _init(name,stat_multiplier, level_growth, raw_value):
		self.name = name
		self.stat_multiplier = stat_multiplier
		self.level_growth = level_growth
		self.raw_value = raw_value
	## Levels up the stat.
	# @param levels_up Number of levels we i ncrease, or decrease.
	# @param old_level The old level.
	func level_up(levels_up, old_level):
		raw_value = raw_value + (raw_value/(level_growth+old_level))*levels_up
	## Gets the public value of the stat, which is computed differently and serves as a
	# guide for the user.
	func get_public_value():
		# Returns the stat value for the user
		return ceil((raw_value*stat_multiplier)/CONSTANT_V)
		
	## Converts this to a dictionary.
	func to_dict():
		var dict = {
			name = self.name,
			stat_multiplier = self.stat_multiplier,
			raw_value = self.raw_value,
			level_growth = self.level_growth
		}
		return dict
	## Generates a Stat object from a dictionary.
	# @param dict The dictionary to use.
	# 
	# @return The Stat object.
	static func from_dict(dict):
		var stat = new(dict["name"],dict["stat_multiplier"], dict["level_growth"], dict["raw_value"])
		return stat

## Attack class.
class Attack:
	## Attack visual name (use localization string like #PCG_Attack_BigBang
	var name
	## Attack internal name.
	var internal_name
	## Attack modifier.
	var attack_modifier
	## Attack animation name.
	var animation_name
	## Attack execute speed (n/s).
	var execute_speed
	
	## Constructor.
	func _init(name, internal_name, attack_modifier, animation_name, execute_speed):
		self.name = name
		self.internal_name = internal_name
		self.attack_modifier = attack_modifier
		self.animation_name = animation_name
		self.execute_speed = execute_speed
		
	## Applies an attack from a BattleEntity to another BattleEntity
	# @param attacker The BattleEntity that is attacking.
	# @param receiver The BattleEntity that receives the attack.
	func do_attack(attacker,receiver):
		#Attack formula=[(Power + Speed) / 2] * AttackModifier
		var speed = attacker.character_info.stats["speed"].get_public_value()
		var power = attacker.character_info.stats["power"].get_public_value()
		if receiver.state extends receiver.state.execute_state:
			receiver.state.get_hit()
		receiver.character_info.HP = receiver.character_info.HP - ((power+speed)/2)*attack_modifier
		
## Character information class
class CharacterInfo:
	
	## Stats for the character, this is a dictionary and each key should be named after
	# the internal name of the stat it contains
	var stats = {}
	
	## Stats available to the character, this is a dictionary and each key should be named after
	# the internal name of the stat it contains
	var attacks = {}
	
	## Character current level
	var level
	
	## Character visualname (should be a localized string like #PCG_Character_Pepper)
	var name
	
	## Character internal name like "pepper"
	var internal_name
	
	## res:// path to this character's overworld sprite scene.
	var sprite_location
	## res:// path to this character's dialog sprite scene.
	var dialog_sprite
	## If this character is controlled by the user.
	var player_controlled = false
	
	## res:// path to this character's portrait sprite scene.
	var portrait_sprite_location
	
	## Health points in public value type.
	var HP = 0
	## Rea points in public value type.
	var MP = 0
	## Constructor.
	func _init():
		pass
		
	## Levels a character up.
	# @param levels_up number of levels to change.
	func level_up(levels_up):
		# Makes all stats level up
		for stat_name in stats:
			var stat = stats[stat_name]
			stat.level_up(levels_up, level)
			HP = stats["vitality"].get_public_value()
			if player_controlled:
				MP = stats["intelligence"].get_public_value()
		level = level+levels_up
	
	## Converts this to a dictionary.
	# TODO: this
	func to_dict():
		pass
		
	## Loads a character_info from file located at res://Stats/<character_name>.json
	# @param character_name Name of the character.
	func load_from_file(character_name):
		var path = "res://Stats/" + character_name + ".json"
		var file_contents = ""
		var final_dict = {}
		var file = File.new()
		level = 1
		if !file.file_exists(path):
			return
		file.open(path, File.READ)
		

		
		while(!file.eof_reached()):
			file_contents = file_contents + file.get_line()
		final_dict.parse_json(file_contents)

		from_dict(final_dict)
	## Generates a battle_entity from a dictionary.
	# @param final_dict Dictionary to generate from.
	func from_dict(final_dict):
		# Base info parsing
		level = final_dict["level"]
		name = final_dict["name"]
		internal_name = final_dict["internal_name"]
		player_controlled = final_dict["player_controlled"]
		sprite_location = final_dict["sprite_location"]
		if final_dict.has("dialog_sprite"):
			dialog_sprite = final_dict["dialog_sprite"]
		# Stats parsing
		var stats_dict = final_dict["stats"]
		for key in stats_dict:
			var stat = stats_dict[key]
			stats[key] = Stat.new(key, stat["stat_multiplier"], stat["level_growth"],stat["raw_value"])
		var attacks_dict = final_dict["attacks"]
		for key in attacks_dict:
			var attack = attacks_dict[key]
			attacks[key] = Attack.new(attack["name"], attack["internal_name"], attack["attack_modifier"], attack["animation_name"], attack["execute_speed"])
		HP = stats["vitality"].get_public_value()
		if player_controlled:
			MP = stats["intelligence"].get_public_value()
		portrait_sprite_location = final_dict["portrait_sprite_location"]
		