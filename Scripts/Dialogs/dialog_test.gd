# ==== Pepper & Carrot Game ====
#
# Purpose: Display the character's dialog text
#
# ==============================

extends Label

# Text speed y chars per second
export var speed = 10
export var character_name = "Pepper"
export var animated_text = "Chavez vive la lucha sigue"
var counter = 0;

func _ready():
	set_process(true)
	get_node("../Character Name").set_text(str(character_name, ":"))

func _process(delta):
	animate_text(delta)
	

func animate_text(delta):
	counter += delta
	var characters = int(counter*speed)
	
	set_text(animated_text.substr(0, characters));
	if (characters > animated_text.length()):
		set_process(false)