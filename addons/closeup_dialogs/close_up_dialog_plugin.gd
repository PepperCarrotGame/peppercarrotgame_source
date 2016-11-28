# ==== Pepper & Carrot tactical RPG ====
#
## @package close_up_dialog_plguin
# Plugin loader for close up dialogs
#
# ==============================
tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("CloseUpDialogController", "Node2D", preload("close_up_dialog.gd"), preload("closeup_dialog_controller_icon.png"))
	add_custom_type("CloseUpDialogNode", "Node2D", preload("close_up_dialog_node.gd"), preload("closeup_dialog_node_icon.png"))
func _exit_tree():
	remove_custom_type("CloseUpDialogController")
	remove_custom_type("CloseUpDialogNode")