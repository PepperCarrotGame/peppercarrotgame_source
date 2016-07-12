# ==== Pepper & Carrot Game ====
#
# Purpose: Standard class for the editor_side part of tools
#
# ==============================
tool
extends Sprite

func _ready():
	if get_tree().is_editor_hint():
		get_node(".").set_hidden(false)
	else:
		get_node(".").set_hidden(true)