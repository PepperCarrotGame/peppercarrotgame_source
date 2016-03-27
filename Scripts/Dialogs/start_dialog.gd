
extends Control

export(NodePath) var first_dialog
# export(Object) var first_dialog

func _ready():
	if (first_dialog):
		var node = get_node(first_dialog)
		if (node.has_method("start")):
			node.start()
