# ==== Pepper & Carrot Game ====
#
# Purpose: Player movement code
#
# ==============================
extends KinematicBody2D

const GRAVITY = 98.0 # Pixels/second
const JUMP_FORCE = 1250.0
# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
const STOP_FORCE = 3000.0
const WALK_MAX_SPEED = 600.0
const MAX_AIRBORNE_SPEED = 600.0
const WALK_FORCE = 50.0

# Not an actual jetpack, just mario styled variable jump height.
const JUMP_JETPACK_FORCE = 100.0
const MAX_JETPACK_TIME = 0.1

# Maximum time you can be in the air and still be able to jump, save the frames and kill the animals.
const JUMP_MAX_AIRBORNE_TIME = 0.2 # 12 frames...
var on_air_time = 0

const AIR_CONTROL_FORCE = 300 # This force is applied when drifting in the air

const AIR_MAX_SPEED = 100
var sprite_root
var is_actually_colliding = false
var state

var velocity = Vector2()
var new_velocity = Vector2()
func _ready():
	set_fixed_process(true)
	state = PlayerStandState.new(self)
	sprite_root = get_node("Sprite")
	var animation_player = get_node("Sprite/PepperSprite/AnimationPlayer")
	animation_player.connect("finished",self,"animation_finished")
	var game_manager = get_node("/root/game_manager")
	game_manager.set_player(self)

func get_camera():
	return get_node("Camera2D")

func animation_finished():
	if state.has_method("animation_finished"):
		var name = get_node("Sprite/PepperSprite/AnimationPlayer").get_current_animation()
		state.animation_finished(name)

func set_animation_speed(speed):
	var animation_player = get_node("Sprite/PepperSprite/AnimationPlayer")
	animation_player.set_speed(speed)

func change_state(new_state):
	if state and state.has_method("OnExit"):
		state.OnExit()
	state = new_state
	if state.has_method("OnEnter"):
		state.OnEnter()

func add_movement(movement):
	new_velocity += movement

func change_animation(new_animation):
	var animation = get_node("Sprite/PepperSprite/AnimationPlayer").get_current_animation()
	if new_animation != animation:
		get_node("Sprite/PepperSprite/AnimationPlayer").play(new_animation)

# Used when transitioning from the main menu.
func interpolate_camera_offset(to_location, main_menu):
	#call_deferred("free_main_menu",main_menu)
	var tween = Tween.new()
	var camera = get_node("Camera2D")
	print("interp")
	add_child(tween)
	tween.interpolate_method(camera, "set_offset", camera.get_offset(), to_location, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_callback(self, 1, "finish_interpolate_camera_offset",tween)
	tween.start()

# Deletes the tween object from memory.
func finish_interpolate_camera_offset(tween):
	tween.free()
func _fixed_process(delta):
	
	new_velocity = Vector2(0,GRAVITY)
	state.Update(delta)
	velocity += new_velocity
	var motion = velocity * delta
	motion = move(motion)
	var n = get_collision_normal()
	if is_colliding():
		is_actually_colliding = true
		if state.has_method("collide"):
			state.collide()

		if new_velocity.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2():
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		else:

			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	else:
		# HACK: Godot is kinda dumb sometimes.
		is_actually_colliding = false
	#DEBUG
	var game_manager = get_node("/root/game_manager")
	var animation_pos = get_node("Sprite/PepperSprite/AnimationPlayer").get_current_animation_pos()
	var animation = get_node("Sprite/PepperSprite/AnimationPlayer").get_current_animation()
	if game_manager.DEBUG:
		var text = "State: %s\nVelocity: %s Animation: %s Animation pos: %s" % [str(state.name), str(velocity), animation, str(animation_pos)]
		get_node("PlayerDebug/DebugLabel").set_text(text)
var input_disabled = false
func disable_input(input_state):
	input_disabled = input_state
func custom_is_action_pressed(action):
	if not input_disabled:
		return Input.is_action_pressed(action)
	else:
		return false
func custom_joy_axis(controller, axis):
	if not input_disabled:
		return Input.get_joy_axis(controller, axis)
	else:
		return 0
# ==============================
# Player state base class, controls jumping and turning around too.
# ==============================
class PlayerState:
	var can_interrupt = true
	var can_turn_around = true
	var can_jump = true
	var walk_left
	var walk_right
	var walk_input_value 
	var name = "PlayerState"
	var player
	const JOYSTICK_MIN = 0.1
	func _init(player):
		self.player = player
	func Update(delta):
		self.walk_left = player.custom_is_action_pressed("left")
		self.walk_right = player.custom_is_action_pressed("right")
		var axis = player.custom_joy_axis(0, JOY_AXIS_0)
		self.walk_input_value = 1
		
		if abs(axis) > JOYSTICK_MIN:
			if axis > 0:
				self.walk_right = true
			else:
				self.walk_left = true
			self.walk_input_value = abs(axis)
		var jump = player.custom_is_action_pressed("jump")
		if can_turn_around:
			if walk_left:
				player.sprite_root.set_scale(Vector2(-1,1))
			elif walk_right:
				player.sprite_root.set_scale(Vector2(1,1))
		if jump and can_jump:
			player.velocity.y = -player.JUMP_FORCE
			player.change_state(player.PlayerJumpState.new(player))
			return

# ==============================
# Standard state for all ground based states, handles leaving the ground
# ==============================
class PlayerGroundState:
	extends PlayerState
	func _init(player).(player):
		player.on_air_time = 0
		pass
	func Update(delta):
		.Update(delta)

		if not player.is_actually_colliding:
			# Make sure the player can still jump for a while before officially leaving the ground.
			player.on_air_time += delta
			if player.on_air_time > player.JUMP_MAX_AIRBORNE_TIME:
				player.change_state(player.PlayerFallState.new(player))

# ==============================
# Player standing state, makes sure the player stops when not running and handles starting to run.
# ==============================
class PlayerStandState:
	extends PlayerGroundState
	
	func _init(player).(player):
		name = "PlayerStandState"
		
	func collide():
		pass
	
	func Update(delta):
		.Update(delta)
		player.change_animation("idle")
		# Stopping shit
		var vsign = sign(player.velocity.x)
		var vlen = abs(player.velocity.x)
		vlen -= player.STOP_FORCE*delta
		if vlen < 0:
			vlen = 0
		player.velocity.x= vlen*vsign
		
		if walk_left or walk_right:
			player.change_state(player.PlayerWalkState.new(player))


# ==============================
# Player walking, makes sure the player never goes over the maximum walking speed.
# ==============================
class PlayerWalkState:
	extends PlayerGroundState
	func _init(player).(player):
		name="PlayerWalkState"
	func Update(delta):
		.Update(delta)
		player.change_animation("walk")
		var jump = player.custom_is_action_pressed("jump")
		
		# Actual max speed
		var defacto_max_walk_speed = player.WALK_MAX_SPEED*walk_input_value
		if walk_left:
			if player.velocity.x >= -defacto_max_walk_speed:
					player.add_movement(Vector2(-player.WALK_FORCE*walk_input_value,0))

		elif walk_right:
			if not player.velocity.x >= defacto_max_walk_speed:
				player.add_movement(Vector2(player.WALK_FORCE*walk_input_value,0))
		else:
			player.change_state(player.PlayerStandState.new(player))

		if abs(player.velocity.x) > defacto_max_walk_speed:
			# This makes sure 100% that the player never goes past the expected maximum speed
			# This is because when sliding down ramps the player just kept getting more speed
			# And we don't want that do we?
			var abv = abs(player.velocity.x)
			var vsign = sign(player.velocity.x)
			var difference = defacto_max_walk_speed-abv
			player.add_movement(Vector2((vsign)*difference, 0))
		player.set_animation_speed(walk_input_value*3)
	func OnExit():
		player.set_animation_speed(1)
# ==============================
# Unused state
# ==============================
class PlayerLandState:
	extends PlayerGroundState
	func _init(player).(player):
		name = "PlayerLandState"
		pass
	func OnEnter():
		player.change_animation("land")
	func Update(delta):
		.Update(delta)
		var jump = player.custom_is_action_pressed("jump")
		var vsign = sign(player.velocity.x)
		var vlen = abs(player.velocity.x)
		vlen -= player.STOP_FORCE*delta
		if vlen < 0:
			vlen = 0
		player.velocity.x= vlen*vsign
		if jump:
			player.velocity.x = player.velocity.x*4
	func animation_finished(name):
		if name == "land":
			player.change_state(player.PlayerStandState.new(player))
			
# ==============================
# Handles aerial control shenanigans and handles landing
# ==============================
class PlayerFallState:
	extends PlayerState

	func _init(player).(player):
		name = "PlayerFallState"
		can_jump=false
	func OnEnter():
		player.change_animation("fall")
	func Update(delta):
		.Update(delta)
		var vsign = sign(player.velocity.x)
		# Try to slow the character down if he's too fast.
		if abs(player.velocity.x) > player.MAX_AIRBORNE_SPEED:
			player.velocity.x = player.MAX_AIRBORNE_SPEED*vsign
		# This code ensures we don't add more velocity if the speed is bigger than it should be
		# However if the player gets speed in any other way this won't limit it
		# This is a HACK, but it should work... right?
		if walk_left:
			if player.velocity.x > -player.AIR_MAX_SPEED:
				player.add_movement(Vector2(-player.AIR_CONTROL_FORCE,0))
		elif walk_right:
			if player.velocity.x < player.AIR_MAX_SPEED:
				player.add_movement(Vector2(player.AIR_CONTROL_FORCE,0))

	func collide():
		# Ran against something, is it the floor? Get normal
		var n = player.get_collision_normal()
		
		if rad2deg(acos(n.dot(Vector2(0, -1)))) < player.FLOOR_ANGLE_TOLERANCE:
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			player.change_state(player.PlayerStandState.new(player))
			
# ==============================
# Handles jump animation and jetpack.
# ==============================
class PlayerJumpState:
	extends PlayerFallState
	var can_jetpack = true
	var jetpack_delta = 0
	func _init(player).(player):
		name = "PlayerJumpState"
	func Update(delta):
		.Update(delta)
		var jump = player.custom_is_action_pressed("jump")
		if not jump:
			can_jetpack = false
		else:
			if can_jetpack:
				player.add_movement(Vector2(0,-player.JUMP_JETPACK_FORCE))
				jetpack_delta = jetpack_delta + delta
				if jetpack_delta > player.MAX_JETPACK_TIME:
					can_jetpack = false
		player.change_animation("p_jump")
	func animation_finished(name):
		if name == "p_jump":
			player.change_state(player.PlayerFallState.new(player))