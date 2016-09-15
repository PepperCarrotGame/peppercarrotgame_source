# ==== Pepper & Carrot Game ====
#
# Purpose: Class for enemies, handles starting battle on contact
#
# ==============================
extends "NPC.gd"

# The class that we should consider to be the player
# on contact it will start a battle.
var player_class = preload("res://Scripts/player.gd")

export (String)var battle_set_path = "res://Stats/BattleSets/demo/demo_battleset.json"

export(bool) var ground_based = false

func _ready():
	var area = get_node("Area2D")
	area.connect("body_enter", self, "_body_enter")
	
func _body_enter(object):
	# TODO: Read this
	print("collision")
	if object extends player_class:
		# TODO: Play start battle animation
		var battle_manager = get_node("/root/battle_manager")
		var BattleSet = load("res://Scripts/Battle/battle_set.gd")
		var battle_set = BattleSet.from_file(battle_set_path)
		battle_manager.start_battle(battle_set)