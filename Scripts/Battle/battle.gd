	# ==== Pepper & Carrot Game ====
#
# Purpose: Handles battles
#
# ==============================

extends Node

### TODO: FIX THIS
# Battle system goes like this:
# There's a waiting period, after that waiting period is over the
# player has to act, if an attack is done and the player is attacked
# while waiting then they will go back to the waitin period

var characters = {}

func _ready():
	pass
	
func get_attack(attacker):
	get_node("CanvasLayer/AttackSelector")._get_attack(attacker)
	
	
# It's time to dududuudududdduduel
# Enemies should be an array
func _start_battle(enemies):
	var game_manager = get_node("/root/game_manager")
	# Gets the player's characters in the correct order
	var player_characters = game_manager.player_data.characters
	var player_data = game_manager.player_data

	# First Character
	var first_character = player_characters[player_data.selected_characters["first"]]
	var first_character_battle = BattleEntity.new()
	first_character_battle.character_info = first_character
	first_character_battle.player_controlled = first_character_battle.character_info.player_controlled
	first_character_battle.position = 0
	characters[first_character.internal_name] = first_character_battle
	# Second Character
	if player_data.selected_characters["second"]:
		var second_character = player_characters[player_data.selected_characters["second"]]
		var second_character_battle = BattleEntity.new()
		second_character_battle.character_info = second_character
		second_character_battle.player_controlled = second_character_battle.character_info.player_controlled
		second_character_battle.position = 1
		characters[second_character.internal_name] = second_character_battle
	
	var enemy_number = 0
	for enemy in enemies:
		print(enemy.character_info)
		characters[enemy.character_info.internal_name + str(enemy_number)] = enemy
		enemy_number = enemy_number+1
		
	
	enemy_number = 0
	# Give character states and set sprite world position
	for key in characters:
		var battle_positions =  get_tree().get_nodes_in_group("battle_position")
		var character = characters[key]
		print("Looping for character: " + character.character_info.name)
		character.state = BattleWaitState.new(character, BattleWaitState, BattleExecuteState)
		character.battle = self
		for position in battle_positions:
			print(str(position.type) + str(position.number))
			if position.number == character.position:
				
				if (position.type == "Player" and character.player_controlled) or (position.type == "Enemy" and not character.player_controlled):
					var sprite = load(character.character_info.sprite_location)
					print(character.character_info.sprite_location)
					var sprite_instance = sprite.instance()
					if not character.player_controlled:
						sprite_instance.set_scale(Vector2(-1,1))
					position.add_child(sprite_instance)
	set_process(true)
	
func _process(delta):
	# Death check
	var playable_side_alive = false
	var non_playable_side_alive = false
	for key in characters:
		var character = characters[key]
		if character.player_controlled and character.character_info.HP > 0:
			playable_side_alive = true
		elif character.character_info.HP > 0:
			non_playable_side_alive = true
	if not non_playable_side_alive:
		# L, L ,L!
		battle_victory()
		return
	elif not playable_side_alive:
		# T W N S M N E!
		battle_loss()
		return
	
	# STATE UPDATE
	for key in characters:
		var character = characters[key]
		character.state.Update(delta)
		
	var game_manger = get_node("/root/game_manager")
	if game_manager.DEBUG:
		var debug_label = get_node("DebugLabel")
		var debug_text = "Battle debug \n"
		debug_text = debug_text + "Characters in the field: " + str(characters.size()) + "\n"
		for key in characters:
			var character = characters[key]
			debug_text = debug_text + "Character " + tr(character.character_info.name) + "\n"
			if character.state extends BattleWaitState:
				debug_text = debug_text + "State: WaitingState, Waiting delta: " + str(character.state.wait_delta) + "\n"
			else:
				debug_text = debug_text + "State: ExecuteState, Execute delta: " + str(character.state.execute_delta) + "\n"
			debug_text = debug_text + "HP: " + str(character.character_info.HP) + " MP: " + str(character.character_info.MP) + "\n"
		debug_label.set_text(debug_text)
		

func battle_victory():
	#TODO: THIS
	var debug_label = get_node("DebugLabel")
	debug_label.set_text("Pepper wins!")
	set_process(false)

	pass

# | |.
# |||_
# Yes, this is loss

func battle_loss():
	# TODO: THIS TOO
	var debug_label = get_node("DebugLabel")
	debug_label.set_text("Pepper did not win.")
	set_process(false)
	pass

class BattleEntity:
	var sprite
	var character_info
	var player_controlled
	var state
	var position
	var battle
	func _init():
		pass
	func receive_damage(pure_damage):
		character_info.HP = character_info.HP - pure_damage
		state.receive_damage(pure_damage)
	
	func change_state(new_state):
		# Call the exit method on the existing battle state, if it exists
		if state:
			state.OnExit()
		# Call the enter method on the new state and assign it
		new_state.OnEnter()
		state = new_state
	func get_attack():
		var result_dict = {"attack": null, "enemy": null}
		if player_controlled:
			battle.get_attack(self)
			# TODO: Present the user with choice
			pass
		else:
			# AI selection
			result_dict["attack"] = character_info.attacks["bite"]
			result_dict["enemy"] = battle.characters["pepper"]
			pass
		return result_dict

class BattleState:
	var battle_entity
	var wait_state
	var execute_state
	func _init(battle_entity, wait_state, execute_state):
		self.battle_entity = battle_entity
		self.wait_state = wait_state
		self.execute_state = execute_state
	func Update(delta):
		pass
	func OnExit():
		pass
	func OnEnter():
		pass
class BattleWaitState:
	extends BattleState
	
	const WAIT_TIME = 200
	var wait_delta = 0
	func OnEnter():
		pass
	func Update(delta):
		.Update(delta)
		# Increment the time for waiting
		wait_delta = wait_delta + battle_entity.character_info.stats["speed"].get_public_value()*delta
		if wait_delta >= WAIT_TIME:
			var new_state = execute_state.new(battle_entity, wait_state, execute_state)
			battle_entity.change_state(new_state)
	func _init(battle_entity, wait_state, execute_state).(battle_entity, wait_state, execute_state):
		pass

class BattleExecuteState:
	extends BattleState
	var execute_delta = 0
	const EXECUTE_TIME = 100
	var attack
	var enemy
	func OnEnter():
		if battle_entity.player_controlled:
			battle_entity.battle.set_process(false)
			battle_entity.get_attack()
		else:
			attack = battle_entity.character_info.attacks["bite"]
			enemy = battle_entity.battle.characters["pepper"]
		
	func attack_callback(attack, enemy):
		self.attack = attack
		self.enemy = enemy
		battle_entity.battle.set_process(true)
	func _init(battle_entity, wait_state, execute_state).(battle_entity, wait_state, execute_state):
		pass

	func Update(delta):
		# Execute delta increment formula is: (Public_Speed/100)*attack_execute_speed
		if execute_delta >= EXECUTE_TIME:
			attack.do_attack(battle_entity, enemy)
			var new_state = wait_state.new(battle_entity, wait_state, execute_state)
			battle_entity.change_state(new_state)
			# TODO
			#battle_entity.sprite.play(attack.animation_name)
		var increment = ((battle_entity.character_info.stats["speed"].get_public_value()/50)*attack.execute_speed)*delta
		execute_delta = execute_delta + increment