# ==== Pepper & Carrot Game ====
#
# Purpose: Display the character's dialog text
#
# ==============================

extends Label

# Text speed in chars per second
export var speed = 10
export var character_name = "Put character name here"
export(bool) var thinking = false 
export(bool) var right_character = false 

var animated_text = ""
var counter = 0

func _ready():
	set_process(true)
	
	# Load character name
	get_node("../Character Name").set_text(str(character_name, ":"))
	
	# Load the text in the animated_text var
	animated_text = get_text()
	
	# If thinking hide talking and show thinking
	if (thinking):
		get_node("../Spike/talking").set_hidden(true)
		get_node("../Spike/thinking").set_hidden(false)
		
	# If character is on the right side flip the spike
	if (right_character):
		get_node("../Spike").set_scale(Vector2(-1, 1))
	

func _process(delta):
	animate_text(delta)
	

func animate_text(delta):
	counter += delta
	var characters = int(counter*speed)
	
	set_text(animated_text.substr(0, characters));
	if (characters > animated_text.length()):
		set_process(false)