# ==== Pepper & Carrot Game ====
#
# Purpose: An in-editor tool that allows the developer to place doors.
#
# ==============================
tool
extends Node2D

export(PackedScene) var scene
export (int) var door_number = 0


func _ready():
	add_to_group("doors")
	if get_tree().is_editor_hint():
		get_node("DebugI").set_hidden(false)
	else:
		get_node("DebugI").set_hidden(false)
	pass
	

func _input(event):
	if(event.is_action("up") and not event.is_echo() and event.is_pressed()):
		print("Player is opening door")
		get_tree().set_input_as_handled()

func _on_body_enter( body ):
	set_process_input(true)
	if not get_tree().is_editor_hint():
		game_manager = get_node("/root/game_manager")
		if game_manager.get_player() == body:
			get_node("Triangle").set_hidden(false)

func _on_body_exit( body ):
	set_process_input(false)
	if not get_tree().is_editor_hint():
		game_manager = get_node("/root/game_manager")
		if game_manager.get_player() == body:
			get_node("Triangle").set_hidden(true)
