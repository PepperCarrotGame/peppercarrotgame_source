
extends VBoxContainer

# member variables here, example:
# var a=2
# var b="textvar"

var battle_entity
var target
var attack
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _get_attack(battle_entity):
	self.battle_entity = battle_entity
	for key in battle_entity.battle.characters:
		var enemy = battle_entity.battle.characters[key]
		if not enemy.player_controlled and enemy.is_alive():
			print(enemy.character_info.name)
			var button = Button.new()
			button.set_text(tr(enemy.character_info.name))
			button.set_meta("enemy",enemy)

			button.connect("pressed", self,"_target_select_callback")
			add_child(button)
			
func _target_select_callback():
	for button in get_children():
		if button.is_pressed():
			target = button.get_meta("enemy")
			break
	for button in get_children():
		remove_child(button)
	
	for key in battle_entity.character_info.attacks:
		var attack = battle_entity.character_info.attacks[key]
		var button = Button.new()
		button.set_text(attack.name)
		button.set_meta("attack",attack)
		print(attack.name)
		button.connect("pressed", self,"_attack_select_callback")
		add_child(button)
		
func _attack_select_callback():
	for button in get_children():
		if button.is_pressed():
			attack = button.get_meta("attack")
			for button in get_children():
				remove_child(button)
			battle_entity.state.attack_callback(attack, target)
			break