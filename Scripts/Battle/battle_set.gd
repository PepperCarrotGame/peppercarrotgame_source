# ==== Pepper & Carrot tactical RPG ====
#
# Purpose: BattlesSets hold information for battles and how they are handled.
#
# ==============================
extends Node

var can_repeat_companions = false
var max_companions = 0
var is_number_of_companions_random
var companion_pool = []
var main_enemy
var random_companions = false
class battle_set_enemy:
	var type
	var adapts_to_player_party_level = false
	var level = 0
	func _init(type, adapts_to_player_party_level, level):
		self.type = type
		self.adapts_to_player_party_level = adapts_to_player_party_level
		self.level = level

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

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