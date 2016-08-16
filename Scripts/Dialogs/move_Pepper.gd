extends Sprite

# member variables here, example:
export var duration=3
export var speed=20
var counter=0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func start():
	set_hidden(false)
	set_process(true)
	

func _process(delta):
	counter += delta
	if (counter <= duration):
		var pos = get_pos()
		pos.x += speed * delta
		set_pos(pos)