
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

var battle_entity
func update_stats():
	var health_bar = get_node("Panel/HealthBar")
	health_bar.set_value(battle_entity.character_info.HP)
	health_bar.set_max(battle_entity.character_info.stats["vitality"].get_public_value())
	
func set_battle_entity(entity):
	battle_entity = entity
	update_stats()