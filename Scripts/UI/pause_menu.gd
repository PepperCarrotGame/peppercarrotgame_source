
extends Container

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	get_node("VBoxContainer/ResumeButton").connect("pressed", self, "_on_ResumeButton_pressed")
	pass


func get_controller_focus():
	get_node("VBoxContainer/ResumeButton").grab_focus()

func _on_ResumeButton_pressed():
	print("t")
	get_tree().set_pause(false)
	set_hidden(true)
	pass # replace with function body
func _on_SaveGameButton_pressed():
	var save_manager = get_node("/root/save_manager")
	save_manager.save_game("autosav")
	save_manager.save_game("1")
	print("save")
	pass # replace with function body
