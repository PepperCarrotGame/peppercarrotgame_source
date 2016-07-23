extends Node

### TODO: FIX THIS
# Battle system goes like this:
# There's a waiting period, after that waiting period is over the
# player has to act, if an attack is done and the player is attacked
# while waiting then they will go back to the waitin period


var characters = {}

func _ready():
	pass
	
	
func _start_battle(enemies):
	
	set_process(true)
	
func _process(delta):
	# Death check
	var playable_side_alive = false
	var non_playable_side_alive = false
	for character in characters:
		if character.player_controlled and character.character_info.HP > 0:
			playable_side_alive = true
		elif character.character_info.HP > 0:
			non_playable_side_alive = true
	if not non_playable_side_alive:
		# L, L ,L!
		battle_victory() 
	elif not playable_side_alive:
		# T W N S M N E!
		battle_loss()
	
	# STATE UPDATE
	for character in characters:
		character.state.Update(delta)

func battle_victory():
	#TODO: THIS
	pass

# | |.
# |||_
# Yes, this is loss

func battle_loss():
	# TODO: THIS TOO
	pass

class BattleEntity:
	var sprite
	var character_info
	var player_controlled
	var state
	func _init():
		pass
	func receive_damage(pure_damage):
		character_info.HP = character_info.HP - pure_damage
		if state extends BattleExecuteState:
			# TODO: INTERRUPTION
			pass
	
	func change_state(new_state):
		# Call the exit method on the existing battle state, if it exists
		if state:
			state.OnExit()
		# Call the enter method on the new state and assign it
		new_state.OnEnter()
		state = new_state
	func get_attack():
		# TODO: FILL THIS BOILERPLATE UP.
		pass

class BattleState:
	func _init(battle_entity):
		pass
	func Update(delta):
		pass

class BattleWaitState:
	extends BattleState
	
	const WAIT_TIME = 200
	var wait_delta
	func OnEnter():
		pass
	func Update(delta):
		.Update(delta)
		wait_delta = wait_delta + battle_entity.character_info.stats["speed"].get_public_value()*delta
		if wait_delta >= WAIT_TIME:
			var new_state = BattleExecuteState.new(battle_entity)
			battle_entity.change_state(new_state)

class BattleExecuteState:
	extends BattleState
	var execute_delta = 0
	const EXECUTE_TIME = 100
	var attack
	var enemy
	func OnEnter():
		attack = battle_entity.get_attack()

	func _init(battle_entity, enemy).(battle_entity):
		enemy = enemy

	func Update(delta):
		# Execute delta increment formula is: (Public_Speed/100)*attack_execute_speed
		if execute_delta >= EXECUTE_TIME:
			attack.do_attack(battle_entity, enemy)
			var new_state = BattleWaitState.new(battle_entity)
			battle_entity.change_state(new_state)
			# TODO
			# battle_entity.sprite.play(attack.animation_name)
		var increment = (battle_entity.character_info.stats["speed"]/100)*attack.execute_speed
		execute_delta = execute_delta + increment