extends Area2D

var player_class = load("res://Scripts/player.gd")
const FADE_SPEED = 2
var fade_delta = 1
var fading_direction = -1
var fading

func _ready():
	connect("body_enter", self, "_handle_body_enter")
	connect("body_exit", self, "_handle_body_exit")
	set_process(true)
func _process(delta):
	if fading:
		fade_delta = fade_delta + ((FADE_SPEED*delta)*fading_direction)
		if fade_delta > 1 or fade_delta < 0:
			if fading_direction == -1:
				fade_delta = 0
			else:
				fade_delta = 1
				
		set_opacity(fade_delta)
	
func _handle_body_enter(object):
	if object extends player_class:
		fading_direction = -1
		fading = true
	pass
	
func _handle_body_exit(object):
	if object extends player_class:
		fading_direction = 1
		fading = true
	pass