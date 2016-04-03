# ==== Pepper & Carrot Game ====
#
# Purpose: Code for the options menu
#
# ==============================

extends Container

var allowed_actions = ["ui_accept", "ui_cancel", "left","right", "down", "up", "jump"]

func _ready():
	get_node(".").connect("resized",self,"_resized")
	
	set_process(true)
	
	for action in allowed_actions:
		var button_scene = ResourceLoader.load("res://Scenes/UI/keybind_button.tscn")
		button_scene = button_scene.instance()
		get_node("ScrollContainer/ButtonContainer").add_child(button_scene)
		button_scene.set_action(action)

func _process(delta):
	var button_container = get_node("ScrollContainer/ButtonContainer")
	var parent_size = Vector2(get_node("ScrollContainer").get_size().x, button_container.get_size().y)
	button_container.set_size(parent_size)

func _on_back_button_pressed():
	var game_manager = get_node("/root/game_manager")
	game_manager.change_to_cached_scene()
	pass


	
func _resized():
	pass
func _draw():
	pass
	
func _on_tree_item_selected():
	
	pass
