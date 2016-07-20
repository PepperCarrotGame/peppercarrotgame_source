# ==== Pepper & Carrot Game ====
#
# Purpose: Manages the battle and it's states.
#
# ==============================

extends Nodes

const WAITING_TIME = 1000

var attack_select_scene

func _ready():
	pass
	
func load_player_characters():
	var game_manager = get_node("/root/game_manager")

func get_attack_for_character(character):
	