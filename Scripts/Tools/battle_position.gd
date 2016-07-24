tool
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

export (String, "Player", "Enemy") var type
export (int) var number

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if not get_tree().is_editor_hint():
		add_to_group("battle_position")
		if not type:
			type = "Player"
	pass


