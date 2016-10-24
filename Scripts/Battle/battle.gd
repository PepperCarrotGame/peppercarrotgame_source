	# ==== Pepper & Carrot Game ====
#
# Purpose: Handles battles
#
# ==============================

extends Node

var character_info = preload("res://Scripts/character_info.gd")
# The space wait time takes on the bar 
const WAIT_TIME_PERCENT = 80.0
const BATTLE_BAR_CLASS = preload("res://Scenes/Battle/UI/battle_bar.tscn")
const BATTLE_PORTRAIT_SCENE = preload("res://Scenes/Battle/UI/battle_portrait.tscn")

### TODO: FIX THIS
# Battle system goes like this:
# There's a waiting period, after that waiting period is over the
# player has to act, if an attack is done and the player is attacked
# while waiting then they will go back to the waiting period

var battle_portraits = []
var battle_bars = []
var characters = {}

func _ready():
	pass
func get_attack(attacker):
	get_node("CanvasLayer/AttackSelector")._get_attack(attacker)

func update_gui():
	# Place the character portrait
	for battle_portrait in battle_portraits:
		var battle_entity = battle_portrait.battle_entity
		if battle_entity:
			var battle_bar = get_node("CanvasLayer/BattleBar")
			# Set pos based on state
			var WAIT_TIME = battle_entity.state.WAIT_TIME
			var EXECUTE_TIME = battle_entity.state.EXECUTE_TIME
			var portrait_pos = battle_bar.get_pos()
			if battle_entity.state extends battle_entity.state.wait_state:
				var wait_delta = battle_entity.state.wait_delta

				var portrait_x_pos_in_var_from_bar_origin = (wait_delta/WAIT_TIME) * (battle_bar.get_size().x*(WAIT_TIME_PERCENT/100))

				portrait_pos.x = battle_bar.get_pos().x + portrait_x_pos_in_var_from_bar_origin
			elif battle_entity.state extends battle_entity.state.execute_state:
				var EXECUTE_TIME_PERCENT = 100.0 - WAIT_TIME_PERCENT
				var execute_origin_pos = battle_bar.get_pos().x + (battle_bar.get_size().x*(WAIT_TIME_PERCENT/100))
				var bar_size_x_limited = battle_bar.get_size().x*(EXECUTE_TIME_PERCENT/100)
				portrait_pos.x = execute_origin_pos + (bar_size_x_limited * (battle_entity.state.execute_delta/EXECUTE_TIME))
			battle_portrait.set_pos(portrait_pos)
			
	for bar in battle_bars:
		bar.update_stats()

# It's time to dududuudududdduduel
func start_battle(battle_set):
	var game_manager = get_node("/root/game_manager")
	var base_enemy = battle_set.main_enemy
	var enemy_pool = battle_set.companion_pool

	
	var enemies = []
	# Add main enemy
	var entity = BattleEntity.from_battle_set_enemy(base_enemy, 0)
	enemies.append(entity)
	
	
	
	
	var max_companions = battle_set.max_companions
	if battle_set.is_number_of_companions_random:
		max_companions = round(rand_range(0,max_companions))
		
	if battle_set.companion_pool.size() > 0:
		if max_companions > 0:
			for i in range(max_companions):
				# Get random enemy
				var enemy
				if battle_set.random_companions:
					enemy = battle_set.companion_pool[round(rand_range(0,battle_set.companion_pool.size()-1))]
				else:
					enemy = battle_set.companion_pool[i-1]
				var entity = BattleEntity.from_battle_set_enemy(enemy, i+1)
				enemies.append(entity)
	var enemy_number = 0
	for enemy in enemies:
		# level adaptation
		if enemy.adapts_to_player_party_level:
			var enemy_level = 0
			var number_of_characters = 0
			for key in game_manager.player_data.characters:
				var character = game_manager.player_data.characters[key]
				enemy_level+=character.level
				number_of_characters+=1
				enemy_level = enemy_level/number_of_characters
				enemy.character_info.level_up(enemy_level-1)
		else:
			var new_level = enemy.level
			enemy.level = 1
			enemy.character_info.level_up(new_level-1)
		characters[enemy.character_info.internal_name + str(enemy_number)] = enemy
		enemy_number = enemy_number+1
		
	
	enemy_number = 0

		

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
	

	# Give character states and set sprite world position
	var current_bar_number = 1
	for key in characters:
		var battle_positions =  get_tree().get_nodes_in_group("battle_position")
		var character = characters[key]
		print("Looping for character: " + character.character_info.name)
		character.state = BattleWaitState.new(character, BattleWaitState, BattleExecuteState, BattleDeadState)
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
		# ADD BATTLE_PORTRAIT
		var battle_portrait = BATTLE_PORTRAIT_SCENE.instance()
		get_node(".").add_child(battle_portrait)
		battle_portrait.battle_entity = character
		battle_portrait.get_node("Sprite").set_texture(load(character.character_info.portrait_sprite_location))
		battle_portraits.append(battle_portrait)
		# ADD HEALTH BAR
		if character.player_controlled:
			var battle_bar = BATTLE_BAR_CLASS.instance()
			battle_bar.set_battle_entity(character)
			battle_bars.append(battle_bar)
			battle_bar.set_pos(Vector2(300,0))
			get_node(".").add_child(battle_bar)
	set_process(true)
	
func _process(delta):
	# Death check
	var playable_side_alive = false
	var non_playable_side_alive = false
	for key in characters:
		var character = characters[key]
		if character.character_info.HP > 0:
			
			if character.player_controlled:
				playable_side_alive = true
			else:
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
		update_debug()
	update_gui()

func update_debug():
	var debug_label = get_node("DebugLabel")
	var debug_text = "Battle debug \n"
	debug_text = debug_text + "Characters in the field: %s \n" % str(characters.size())
	for key in characters:
		var character = characters[key]
		debug_text = debug_text + "Character %s \n" % tr(character.character_info.name)
		if character.state extends BattleWaitState:
			debug_text = debug_text + "State: WaitingState, Waiting delta: %s \n" % str(character.state.wait_delta)
		elif character.state extends BattleExecuteState:
			debug_text = debug_text + "State: ExecuteState, Execute delta: %s \n" % str(character.state.execute_delta)
		else:
			debug_text = debug_text + "State: DeadState, No delta." + "\n"
		debug_text = debug_text + "HP: %s MP: %s \n" % [str(character.character_info.HP), str(character.character_info.MP)]
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
	var adapts_to_player_party_level = false
	func is_alive():
		return not state extends state.dead_state
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
	static func from_battle_set_enemy(enemy_set, position):
		var character_info = load("res://Scripts/character_info.gd")
		var charinfo = character_info.CharacterInfo.new()
		charinfo.load_from_file(enemy_set.type)
		
		var battle_entity = new()
		battle_entity.character_info = charinfo
		battle_entity.player_controlled = false
		battle_entity.position = position
		battle_entity.adapts_to_player_party_level = enemy_set.adapts_to_player_party_level
		return battle_entity

class BattleState:
	const EXECUTE_TIME = 100
	const WAIT_TIME = 200
	var battle_entity
	var wait_state
	var execute_state
	var dead_state
	func _init(battle_entity, wait_state, execute_state, dead_state):
		self.battle_entity = battle_entity
		self.wait_state = wait_state
		self.execute_state = execute_state
		self.dead_state = dead_state
	func Update(delta):
		if battle_entity.character_info.HP <= 0:
			battle_entity.character_info.HP = 0
			# TODO: Play death animation or something
			var new_state = dead_state.new(battle_entity, wait_state, execute_state, dead_state)
			battle_entity.change_state(new_state)
	func OnExit():
		pass
	func OnEnter():
		pass
class BattleDeadState:
	extends BattleState
	func OnEnter():
		.OnEnter()
	func OnExit():
		.OnExit()
	func _init(battle_entity, wait_state, execute_state, dead_state).(battle_entity, wait_state, execute_state, dead_state):
		pass
	func Update(delta):
		.Update(delta)
class BattleWaitState:
	extends BattleState
	
	
	var wait_delta = 0
	func OnEnter():
		pass
	func Update(delta):
		.Update(delta)
		# Increment the time for waiting
		wait_delta = wait_delta + battle_entity.character_info.stats["speed"].get_public_value()*delta
		if wait_delta >= WAIT_TIME:
			var new_state = execute_state.new(battle_entity, wait_state, execute_state, dead_state)
			battle_entity.change_state(new_state)
	func _init(battle_entity, wait_state, execute_state, dead_state).(battle_entity, wait_state, execute_state, dead_state):
		pass

class BattleExecuteState:
	extends BattleState
	var execute_delta = 0
	
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
	func _init(battle_entity, wait_state, execute_state, dead_state).(battle_entity, wait_state, execute_state, dead_state):
		pass

	func Update(delta):
		# Execute delta increment formula is: (Public_Speed/100)*attack_execute_speed
		if execute_delta >= EXECUTE_TIME:
			attack.do_attack(battle_entity, enemy)
			var new_state = wait_state.new(battle_entity, wait_state, execute_state, dead_state)
			battle_entity.change_state(new_state)
			# TODO
			#battle_entity.sprite.play(attack.animation_name)
		var increment = ((battle_entity.character_info.stats["speed"].get_public_value()/50)*attack.execute_speed)*delta
		execute_delta = execute_delta + increment
	func get_hit():
		var new_state = wait_state.new(battle_entity, wait_state, execute_state, dead_state)
		new_state.wait_delta = WAIT_TIME*0.20
		battle_entity.change_state(new_state)
		print("Interrupt!")