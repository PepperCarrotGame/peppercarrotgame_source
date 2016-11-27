# ==== Pepper & Carrot tactical RPG ====
#
## @package close_up_dialog_node
# Contains information of each dialog line
#
# ==============================
tool
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

const SPRITE_LOCATION = "res://Assets/Images/UI/character_closeups/"
export(String) var character
export(String, "normal", "happy", "sad") var emotion = "normal"
export(NodePath) var next_dialog = null
export(String, "Left", "Right") var position = "Left"
export(String) var text
var character_information

func _ready():
	print("asd")
	if not get_tree().is_editor_hint():
		var character_info = preload("res://Scripts/character_info.gd")
		character_information = character_info.CharacterInfo.new()
		character_information.load_from_file(character)
		
## Returns the next dialog.
# @return The next dialog node.
func get_next_dialog():
	return get_node(next_dialog)