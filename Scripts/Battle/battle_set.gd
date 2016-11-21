# ==== Pepper & Carrot tactical RPG ====
#
## @package battle_set
# BattlesSets hold information for battles and how they are handled.
#
# ==============================
extends Node

## If there can be more than one companion generated from the same type.
var can_repeat_companions = false

## Max number of companions, not including the main one.
var max_companions = 0

var is_number_of_companions_random = false

## Extra companion battle_set_enemies
var companion_pool = []

## Main enemy, always appears
var main_enemy

## If the extra companions are random.
var random_companions = false

## This class holds the information for each character in the companion_pool
class battle_set_enemy:
	## Enemy type, should be a string (internal name)
	var type
	## If the level should be evened out with the player's.
	var adapts_to_player_party_level = false
	## Starting level, only useful if adapts_to_player_party_level
	var level = 0
	
	## Construct
	# @param type Enemy type
	# @param adapts_to_player_party_level
	# @level Starting Level.
	func _init(type, adapts_to_player_party_level, level):
		self.type = type
		self.adapts_to_player_party_level = adapts_to_player_party_level
		self.level = level

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
## Generate BattleSet from file.
# @param file_path File path to generate from.
#
# @return New BattleSet.
static func from_file(file_path):
	var file = File.new()
	if !file.file_exists(file_path):
		return
	file.open(file_path, File.READ)
	# Parse from file
	var file_contents = ""
	var final_dict = {}
	while(!file.eof_reached()):
		file_contents = file_contents + file.get_line()
	final_dict.parse_json(file_contents)
	var battle_set = new()
	battle_set.can_repeat_companions = final_dict["can_repeat_companions"]
	battle_set.max_companions = final_dict["max_companions"]
	battle_set.is_number_of_companions_random = final_dict["is_number_of_companions_random"]
	battle_set.random_companions = final_dict["random_companions"]
	var main_enemy = final_dict["main_enemy"]
	var level = 1
	if not main_enemy.has("adapts_to_player_party_level"):
		level = main_enemy["level"]
	battle_set.main_enemy = battle_set_enemy.new(main_enemy["type"], main_enemy["adapts_to_player_party_level"],level)

	for companion in final_dict["companion_pool"]:
		var level = 1
		if not companion.has("adapts_to_player_party_level"):
			level = companion["level"]
		battle_set.companion_pool.append(battle_set_enemy.new(companion["type"],companion["adapts_to_player_party_level"],level))
	return battle_set