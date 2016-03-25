# ==== Pepper & Carrot Game ====
#
# Purpose: Code for the options menu
#
# ==============================

extends Container

var allowed_actions = ["ui_accept", "ui_cancel", "left","right", "down", "up", "jump"]

func _ready():
	# Setup tree
	var tree = get_node("tree")
	tree.set_hide_root(true)
	tree.set_columns(2)
	tree.set_select_mode(tree.SELECT_ROW)
	
	var input_event
	tree.create_item()
	for action in allowed_actions:
		# First input should always be keyboard, but just in case
		input_event = InputMap.get_action_list(action)[0]
		if(input_event.type == InputEvent.KEY):
			if(input_event != null):
				var item = tree.create_item(tree.get_root())
				item.set_text(0,tr("input_" + action))
				item.set_text(1,OS.get_scancode_string(input_event.scancode))
		else:
			print("First input in action should always be of type KEY")
	pass




func _on_back_button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.change_to_cached_scene()


func _on_tree_item_selected():
	
	pass
